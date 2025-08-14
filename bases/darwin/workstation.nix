{
  config,
  pkgs,
  ...
}: let
  inherit (config.hostCfg) username;
in {
  imports = [
    ../../components/common/extra/nix-settings.nix

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
      "libreoffice-still"
      "firefox"
      "visual-studio-code"
      "alt-tab"
      "rectangle"
    ];
  };

  home-manager.users.${username}.programs.zsh.shellAliases."o" = "open";
}
