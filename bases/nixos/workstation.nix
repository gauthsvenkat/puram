# NOTE: This config will put together a very basic workstation
# with tools and services that I prefer on all workstations.
# Desktop environment is chosen downstream.
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
    ../../modules/common/extra/wallpaper.nix

    ../../modules/nixos/extra/vial.nix

    ../../modules/nixos/gui/wezterm.nix

    ../../modules/nixos/hardware/bluetooth.nix

    ../../modules/nixos/services/docker.nix
    ../../modules/nixos/services/pipewire.nix

    ../common/workstation.nix

    ./system.nix
  ];

  home-manager.users.${username} = {
    xdg.autostart.enable = true;

    home.packages = with pkgs; [
      firefox
      libreoffice-still
      mpv
      nerd-fonts.jetbrains-mono
      spotify
      vscode

      #NOTE: This is required for neovim on linux
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
