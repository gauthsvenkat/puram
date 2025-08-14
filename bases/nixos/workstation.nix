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

    ../../components/common/terminal/aider.nix
    ../../components/common/terminal/bat.nix
    ../../components/common/terminal/btop.nix
    ../../components/common/terminal/claude-code.nix
    ../../components/common/terminal/development.nix
    ../../components/common/terminal/direnv.nix
    ../../components/common/terminal/eza.nix
    ../../components/common/terminal/fastfetch.nix
    ../../components/common/terminal/fzf.nix
    ../../components/common/terminal/git.nix
    ../../components/common/terminal/just.nix
    ../../components/common/terminal/lazygit.nix
    ../../components/common/terminal/mcfly.nix
    ../../components/common/terminal/neovim.nix
    ../../components/common/terminal/nh.nix
    ../../components/common/terminal/spotify-player.nix
    ../../components/common/terminal/utils.nix
    ../../components/common/terminal/zoxide.nix
    ../../components/common/terminal/zsh.nix

    ../../components/nixos/extra/spotify.nix
    ../../components/nixos/extra/vial.nix

    ../../components/nixos/gui/wezterm.nix

    ../../components/nixos/hardware/bluetooth.nix

    ../../components/nixos/services/docker.nix
    ../../components/nixos/services/pipewire.nix

    ./system.nix
  ];

  home-manager.users.${username} = {
    xdg.autostart.enable = true;

    home.packages = with pkgs; [
      firefox
      libreoffice-still
      mpv
      nerd-fonts.jetbrains-mono
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
