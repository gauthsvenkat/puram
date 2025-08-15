{
  config,
  pkgs,
  ...
}: let
  inherit (config.hostCfg) username;
in {
  imports = [
    ../../components/common/development/lua.nix
    ../../components/common/development/misc.nix
    ../../components/common/development/nix.nix
    ../../components/common/development/python.nix
    ../../components/common/development/rust.nix

    ../../components/common/extra/nix-settings.nix

    ../../components/common/terminal/aider.nix
    ../../components/common/terminal/bat.nix
    ../../components/common/terminal/btop.nix
    ../../components/common/terminal/claude-code.nix
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

    ../../components/darwin/gui/wezterm.nix

    ../../components/darwin/homebrew.nix

    ../../components/darwin/services/kanata.nix

    ../../components/darwin/system/defaults.nix
    ../../components/darwin/system/misc.nix

    ../../components/common/home-manager.nix

    ./system.nix
  ];

  fonts.packages = [pkgs.nerd-fonts.jetbrains-mono];

  homebrew = {
    brews = ["mpv"];
    casks = [
      "alt-tab"
      "docker-desktop"
      "firefox"
      "iterm2"
      "libreoffice-still"
      "middleclick"
      "rectangle"
      "visual-studio-code"
    ];
  };

  home-manager.users.${username}.programs.zsh.shellAliases."o" = "open";
}
