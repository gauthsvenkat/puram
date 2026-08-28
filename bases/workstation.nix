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
    ../modules/nixos/hardware/bluetooth.nix
    ../modules/nixos/hardware/vial.nix

    ../modules/nixos/services/docker.nix
    ../modules/nixos/services/pipewire.nix

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
      ../modules/home-manager/atuin.nix
      ../modules/home-manager/bat.nix
      ../modules/home-manager/btop.nix
      ../modules/home-manager/claude-code.nix
      ../modules/home-manager/direnv.nix
      ../modules/home-manager/eza.nix
      ../modules/home-manager/fastfetch.nix
      ../modules/home-manager/git.nix
      ../modules/home-manager/just.nix
      ../modules/home-manager/lazygit.nix
      ../modules/home-manager/lua.nix
      ../modules/home-manager/neovim.nix
      ../modules/home-manager/nh.nix
      ../modules/home-manager/nix.nix
      ../modules/home-manager/pre-commit.nix
      ../modules/home-manager/python.nix
      ../modules/home-manager/rust.nix
      ../modules/home-manager/starship.nix
      ../modules/home-manager/utils.nix
      ../modules/home-manager/wallpaper.nix
      ../modules/home-manager/wezterm.nix
      ../modules/home-manager/yazi.nix
      ../modules/home-manager/zoxide.nix
      ../modules/home-manager/zsh.nix
    ];

    fonts.fontconfig = {
      enable = true;
      defaultFonts.monospace = [ "JetBrainsMono Nerd Font Mono" ];
    };

    home = {
      packages = with pkgs; [
        firefox
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
