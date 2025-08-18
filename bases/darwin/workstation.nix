{
  config,
  pkgs,
  ...
}:
let
  inherit (config.hostCfg) username;
in
{
  imports = [
    ../../components/common/extra/wallpaper.nix
    ../../components/common/home-manager.nix

    ../../components/darwin/gui/wezterm.nix

    ../../components/darwin/homebrew.nix

    ../../components/darwin/services/kanata.nix

    ../../components/darwin/system/defaults.nix
    ../../components/darwin/system/keybindings.nix
    ../../components/darwin/system/misc.nix

    ../common/workstation.nix

    ./system.nix
  ];

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  homebrew = {
    brews = [ "mpv" ];
    casks = [
      "alt-tab"
      "docker-desktop"
      "firefox"
      "iterm2"
      "libreoffice-still"
      "middleclick"
      "monitorcontrol"
      "rectangle"
      "scroll-reverser"
      "spotify"
      "visual-studio-code"
    ];
  };

  home-manager.users.${username}.programs.zsh.shellAliases."o" = "open";
}
