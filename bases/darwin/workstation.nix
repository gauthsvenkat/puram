{
  hostCfg,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username;
in
{
  imports = [
    ../../modules/common/extra/wallpaper.nix
    ../../modules/common/home-manager.nix

    ../../modules/darwin/gui/wezterm.nix

    ../../modules/darwin/homebrew.nix

    ../../modules/darwin/services/kanata.nix

    ../../modules/darwin/system/defaults.nix
    ../../modules/darwin/system/keybindings.nix
    ../../modules/darwin/system/misc.nix

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
