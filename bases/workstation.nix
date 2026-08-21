{
  config,
  hostCfg,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username homeDirectory;
in
{
  imports = [
    ../modules/nixos/extra/vial.nix

    ../modules/nixos/hardware/bluetooth.nix

    ../modules/nixos/services/docker.nix
    ../modules/nixos/services/pipewire.nix

    ../modules/nixos/system/zsh.nix

    ./system.nix
  ];

  programs.ssh.startAgent = true;

  services = {
    gvfs.enable = true;
    udisks2.enable = true;
    upower.enable = true;
  };

  home-manager.users.${username} = {
    imports = [
      ../modules/home-manager/cli/atuin.nix
      ../modules/home-manager/cli/bat.nix
      ../modules/home-manager/cli/btop.nix
      ../modules/home-manager/cli/claude-code.nix
      ../modules/home-manager/cli/direnv.nix
      ../modules/home-manager/cli/eza.nix
      ../modules/home-manager/cli/fastfetch.nix
      ../modules/home-manager/cli/git.nix
      ../modules/home-manager/cli/just.nix
      ../modules/home-manager/cli/lazygit.nix
      ../modules/home-manager/cli/neovim.nix
      ../modules/home-manager/cli/nh.nix
      ../modules/home-manager/cli/pre-commit.nix
      ../modules/home-manager/cli/starship.nix
      ../modules/home-manager/cli/utils.nix
      ../modules/home-manager/cli/zoxide.nix
      ../modules/home-manager/cli/zsh.nix

      ../modules/home-manager/development/lua.nix
      ../modules/home-manager/development/misc.nix
      ../modules/home-manager/development/nix.nix
      ../modules/home-manager/development/python.nix
      ../modules/home-manager/development/rust.nix

      ../modules/home-manager/extra/wallpaper.nix

      ../modules/home-manager/gui/wezterm.nix
    ];

    fonts.fontconfig = {
      enable = true;
      defaultFonts.monospace = [ "JetBrainsMono Nerd Font Mono" ];
    };

    home = {
      packages = with pkgs; [
        firefox
        gh
        libreoffice-still
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
      starship.presets = [
        "bracketed-segments"
        "nerd-font-symbols"
      ];

      zsh.shellAliases = {
        "o" = "xdg-open";
        "open" = "xdg-open";
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
