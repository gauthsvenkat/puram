# NOTE: This config will put together a very basic workstation
# with tools and services that I prefer on all workstations.
# Desktop environment is chosen downstream.
{
  config,
  pkgs,
  ...
}: let
  inherit (config.hostCfg) username;
in {
  imports = [
    ../../components/common/extra/wallpaper.nix

    ../../components/nixos/extra/vial.nix

    ../../components/nixos/gui/wezterm.nix

    ../../components/nixos/hardware/bluetooth.nix

    ../../components/nixos/services/docker.nix
    ../../components/nixos/services/pipewire.nix

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
      defaultFonts.monospace = ["JetBrainsMono Nerd Font Mono"];
    };

    programs.zsh.shellAliases = {
      "o" = "xdg-open";
      "open" = "xdg-open";
    };
  };
}
