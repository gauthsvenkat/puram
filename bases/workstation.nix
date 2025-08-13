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
    ../components/extra/vial.nix
    ../components/extra/wallpaper.nix

    ../components/terminal/aider.nix
    ../components/terminal/bat.nix
    ../components/terminal/btop.nix
    ../components/terminal/claude-code.nix
    ../components/terminal/direnv.nix
    ../components/terminal/eza.nix
    ../components/terminal/fastfetch.nix
    ../components/terminal/fzf.nix
    ../components/terminal/git.nix
    ../components/terminal/just.nix
    ../components/terminal/lazygit.nix
    ../components/terminal/mcfly.nix
    ../components/terminal/neovim.nix
    ../components/terminal/nh.nix
    ../components/terminal/spotify-player.nix
    ../components/terminal/utils.nix
    ../components/terminal/wezterm.nix
    ../components/terminal/zoxide.nix
    ../components/terminal/zsh.nix
  ];

  home-manager.users.${username} = {
    xdg.autostart.enable = true;

    home.packages = with pkgs; [
      firefox
      libreoffice-still
      mpv
      nerd-fonts.jetbrains-mono
      vscode
    ];

    home.file.".p10k.zsh".source = ../notnix/configs/p10k.zsh;

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
