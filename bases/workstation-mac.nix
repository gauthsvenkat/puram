{
  config,
  inputs,
  pkgs,
  ...
}: let
  inherit (config.hostCfg) username;
in {
  imports = [
    ../components/darwin/homebrew.nix
    ../components/darwin/misc.nix

    inputs.home-manager-darwin.darwinModules.home-manager
    ../components/system/home-manager.nix

    ../components/extra/development.nix
    ../components/extra/nix-settings.nix

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

    ../components/wallpaper
  ];

  fonts.packages = [pkgs.nerd-fonts.jetbrains-mono];

  homebrew = {
    brews = ["mpv"];
    casks = [
      "libreoffice-still"
      "firefox"
      "visual-studio-code"
    ];
  };

  home-manager.users.${username}.programs.zsh.shellAliases."o" = "open";
}
