# This config will put together a very basic workstation
# with tools and services that I prefer on all workstations.
# NOTE: Desktop environment is chosen downstream.
{
  config,
  pkgs,
  ...
}: let
  inherit (config.hostCfg) username;
in {
  imports = [
    ./system.nix

    ../components/hardware/bluetooth.nix

    ../components/services/docker.nix
    ../components/services/pipewire.nix

    ../components/extra/development.nix
    ../components/extra/spotify.nix

    ../components/terminal/aider.nix
    ../components/terminal/bat.nix
    ../components/terminal/btop.nix
    ../components/terminal/claude-code.nix
    ../components/terminal/direnv.nix
    ../components/terminal/eza.nix
    ../components/terminal/fastfetch.nix
    ../components/terminal/fzf.nix
    ../components/terminal/git.nix
    ../components/terminal/lazygit.nix
    ../components/terminal/mcfly.nix
    ../components/terminal/neovim.nix
    ../components/terminal/spotify-player.nix
    ../components/terminal/wezterm.nix
    ../components/terminal/zoxide.nix
    ../components/terminal/zsh.nix

    ../components/wallpaper
  ];

  home-manager.users.${username} = {
    xdg.autostart.enable = true;

    home.packages = with pkgs; [
      firefox
      jq
      libreoffice-still
      mpv
      nerd-fonts.jetbrains-mono
      vscode
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
