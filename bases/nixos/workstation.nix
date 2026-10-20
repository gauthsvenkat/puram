{
  allTargetCfgs,
  targetCfg,
  lib,
  pkgs,
  ...
}:
let
  inherit (targetCfg) username homeDirectory;
  sshKey = "${homeDirectory}/.ssh/id_ed25519";
  # filterAttrs :: (hostname::String -> targetCfg -> Bool) -> { hostname::String -> targetCfg } -> { hostname::String -> targetCfg }
  # :: { hostname::String -> targetCfg }, hosts with an sshHostKey
  serverCfgs = lib.filterAttrs (_: targetCfg: targetCfg ? sshHostKey) allTargetCfgs;
  tailnet = allTargetCfgs."infra".tailscale.dnsName;
  router = allTargetCfgs."flint-2";
in
{
  imports = [
    ../../modules/nixos/hardware/bluetooth.nix
    ../../modules/nixos/hardware/vial.nix

    ../../modules/nixos/services/docker.nix
    ../../modules/nixos/services/pipewire.nix

    ./system.nix
  ];

  programs.ssh = {
    # mapAttrs :: (hostname::String -> targetCfg -> knownHost) -> { hostname::String -> targetCfg } -> { hostname::String -> knownHost }
    #   where knownHost = { extraHostNames :: [ String ]; publicKey :: String }
    knownHosts = lib.mapAttrs (hostName: targetCfg: {
      extraHostNames = [
        "${hostName}.lan"
        "${hostName}.${tailnet}"
      ];
      publicKey = targetCfg.sshHostKey;
    }) serverCfgs;
    startAgent = true;
  };

  services = {
    gvfs.enable = true;
    udisks2.enable = true;
    upower.enable = true;
  };

  home-manager.users.${username} = {
    imports = [
      ../../modules/home-manager/atuin.nix
      ../../modules/home-manager/bat.nix
      ../../modules/home-manager/btop.nix
      ../../modules/home-manager/claude-code.nix
      ../../modules/home-manager/direnv.nix
      ../../modules/home-manager/eza.nix
      ../../modules/home-manager/fastfetch.nix
      ../../modules/home-manager/firefox.nix
      ../../modules/home-manager/git.nix
      ../../modules/home-manager/just.nix
      ../../modules/home-manager/lazygit.nix
      ../../modules/home-manager/lua.nix
      ../../modules/home-manager/neovim.nix
      ../../modules/home-manager/nh.nix
      ../../modules/home-manager/nix.nix
      ../../modules/home-manager/pre-commit.nix
      ../../modules/home-manager/python.nix
      ../../modules/home-manager/rust.nix
      ../../modules/home-manager/starship.nix
      ../../modules/home-manager/utils.nix
      ../../modules/home-manager/wallpaper.nix
      ../../modules/home-manager/wezterm.nix
      ../../modules/home-manager/yazi.nix
      ../../modules/home-manager/zoxide.nix
      ../../modules/home-manager/zsh.nix
    ];

    fonts.fontconfig = {
      enable = true;
      defaultFonts.monospace = [ "JetBrainsMono Nerd Font Mono" ];
    };

    home = {
      packages = with pkgs; [
        gh
        libreoffice-stable
        mpv
        nerd-fonts.jetbrains-mono
        sops
        spotify
        stirling-pdf-desktop
        vscode

        # Required for neovim clipboard integration on linux.
        wl-clipboard
      ];
      sessionVariables.SOPS_AGE_KEY_CMD = "${lib.getExe pkgs.ssh-to-age} -private-key -i ${sshKey}";
    };

    programs = {
      ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings =
          let
            # concatMapAttrs :: (hostname::String -> targetCfg -> { alias::String -> sshHost }) -> { hostname::String -> targetCfg } -> { alias::String -> sshHost }
            #   where sshHost = { HostName :: String; User :: String }
            # :: { alias::String -> sshHost }, `<hostname>`, `<hostname>-root` and `<hostname>-ts` per server
            serverAliases = lib.concatMapAttrs (hostName: targetCfg: {
              ${hostName} = {
                HostName = "${hostName}.lan";
                User = targetCfg.username;
              };
              "${hostName}-root" = {
                HostName = "${hostName}.lan";
                User = "root";
              };
              "${hostName}-ts" = {
                HostName = "${hostName}.${tailnet}";
                User = targetCfg.username;
              };
            }) serverCfgs;
          in
          serverAliases
          // {
            ${router.hostname} = {
              HostName = router.lan.ip;
              HostKeyAlias = router.hostname;
              User = "root";
            };
            # Reuse one connection for consecutive git operations.
            "github.com" = {
              ControlMaster = "auto";
              ControlPath = "/run/user/%i/ssh-%C";
              ControlPersist = "10m";
            };
          };
      };

      starship.presets = [
        "bracketed-segments"
        "nerd-font-symbols"
      ];

      zsh.shellAliases =
        let
          xdg-open = lib.getExe' pkgs.xdg-utils "xdg-open";
        in
        {
          "o" = xdg-open;
          "open" = xdg-open;
        };
    };

    xdg.autostart.enable = true;
  };

  sops.age.sshKeyPaths = [ sshKey ];
}
