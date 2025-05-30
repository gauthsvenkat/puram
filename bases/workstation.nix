# This config will put together a very basic workstation
# with tools and services that I prefer on all workstations.

# NOTE: Desktop environment is chosen in the host.

{ pkgs, username, ... }:
{
  imports = [
    ./system.nix

    ../components/core/services/pipewire.nix

    ../components/core/home-manager.nix

    ../components/optional/bluetooth.nix
    ../components/optional/development.nix
    ../components/optional/spotify.nix

    ../components/optional/services/docker.nix

    ../components/optional/terminal/bat.nix
    ../components/optional/terminal/btop.nix
    ../components/optional/terminal/direnv.nix
    ../components/optional/terminal/eza.nix
    ../components/optional/terminal/fzf.nix
    ../components/optional/terminal/git.nix
    ../components/optional/terminal/lazygit.nix
    ../components/optional/terminal/mcfly.nix
    ../components/optional/terminal/neovim.nix
    ../components/optional/terminal/wezterm.nix
    ../components/optional/terminal/zoxide.nix
    ../components/optional/terminal/zsh.nix
  ];

  home-manager.users.${username} = {
    fonts.fontconfig.enable = true;

    xdg.autostart.enable = true;

    home.packages = with pkgs; [
      vscode
      libreoffice-still
      mpv
    ];

    programs.zsh.shellAliases = {
      "o" = "xdg-open";
      "open" = "xdg-open";
    };
  };
}
