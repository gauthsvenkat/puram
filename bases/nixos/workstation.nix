{
  allHostCfgs,
  config,
  hostCfg,
  lib,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username homeDirectory;
  # :: { hostname -> hostCfg }
  serverCfgs = lib.filterAttrs (_: hostCfg: hostCfg ? sshHostKey) allHostCfgs;
  tailnet = "tailnet.ts.net";
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
    knownHosts = lib.mapAttrs (hostName: hostCfg: {
      extraHostNames = [ "${hostName}.${tailnet}" ];
      publicKey = hostCfg.sshHostKey;
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
      sessionVariables.SOPS_AGE_KEY_FILE = config.sops.age.keyFile;
    };

    programs = {
      ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings =
          lib.concatMapAttrs (hostName: hostCfg: {
            ${hostName} = {
              HostName = "${hostName}.${tailnet}";
              User = hostCfg.username;
            };
            "${hostName}-root" = {
              HostName = "${hostName}.${tailnet}";
              User = "root";
            };
          }) serverCfgs
          // {
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

  sops.age = {
    generateKey = true;
    keyFile = "${homeDirectory}/.config/sops/age/keys.txt";
    sshKeyPaths = [ "${homeDirectory}/.ssh/id_ed25519" ];
  };
}
