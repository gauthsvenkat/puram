{
  hostCfg,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username;
in
{
  imports = [
    ../../modules/nixos/extra/vial.nix

    ../../modules/nixos/hardware/bluetooth.nix

    ../../modules/nixos/services/docker.nix
    ../../modules/nixos/services/pipewire.nix

    ../common/workstation.nix

    ./system.nix
  ];

  programs.ssh.startAgent = true;

  services = {
    gvfs.enable = true;
    udisks2.enable = true;
  };

  home-manager.users.${username} = {
    imports = [
      ../../modules/home-manager/extra/wallpaper.nix
    ];

    xdg.autostart.enable = true;

    home.packages = with pkgs; [
      firefox
      libreoffice-still
      mpv
      nerd-fonts.jetbrains-mono
      spotify
      stirling-pdf-desktop
      vscode

      # Required for neovim clipboard integration on linux.
      wl-clipboard
    ];

    fonts.fontconfig = {
      enable = true;
      defaultFonts.monospace = [ "JetBrainsMono Nerd Font Mono" ];
    };

    programs.zsh.shellAliases = {
      "o" = "xdg-open";
      "open" = "xdg-open";
    };
  };
}
