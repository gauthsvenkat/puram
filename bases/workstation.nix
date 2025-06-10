# This config will put together a very basic workstation
# with tools and services that I prefer on all workstations.
# NOTE: Desktop environment is chosen in the host.
{
  pkgs,
  username,
  ...
}: {
  imports = [
    ./system.nix

    ../components/gui/pipewire.nix

    ../components/hardware/bluetooth.nix

    ../components/services/docker.nix

    ../components/extra/development.nix
    ../components/extra/spotify.nix

    ../components/terminal/bat.nix
    ../components/terminal/btop.nix
    ../components/terminal/direnv.nix
    ../components/terminal/eza.nix
    ../components/terminal/fzf.nix
    ../components/terminal/git.nix
    ../components/terminal/lazygit.nix
    ../components/terminal/mcfly.nix
    ../components/terminal/neovim.nix
    ../components/terminal/wezterm.nix
    ../components/terminal/zoxide.nix
    ../components/terminal/zsh.nix
  ];

  home-manager.users.${username} = {
    fonts.fontconfig.enable = true;

    xdg.autostart.enable = true;

    home.packages = with pkgs; [
      firefox
      jq
      libreoffice-still
      mpv
      vscode
    ];

    programs.zsh.shellAliases = {
      "o" = "xdg-open";
      "open" = "xdg-open";
    };
  };
}
