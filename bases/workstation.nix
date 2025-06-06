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

    ../components/home-manager.nix

    ../components/gui/pipewire.nix
    ../components/gui/wezterm.nix

    ../components/services/docker.nix

    ../components/other/bluetooth.nix
    ../components/other/development.nix
    ../components/other/spotify.nix

    ../components/cli/bat.nix
    ../components/cli/btop.nix
    ../components/cli/direnv.nix
    ../components/cli/eza.nix
    ../components/cli/fzf.nix
    ../components/cli/git.nix
    ../components/cli/lazygit.nix
    ../components/cli/mcfly.nix
    ../components/cli/neovim.nix
    ../components/cli/zoxide.nix
    ../components/cli/zsh.nix
  ];

  home-manager.users.${username} = {
    fonts.fontconfig.enable = true;

    xdg.autostart.enable = true;

    home.packages = with pkgs; [
      vscode
      libreoffice-still
      mpv
      firefox
    ];

    programs.zsh.shellAliases = {
      "o" = "xdg-open";
      "open" = "xdg-open";
    };
  };
}
