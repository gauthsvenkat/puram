{ config, ... }:
let
  inherit (config.hostCfg) username;
in
{
  home-manager.users.${username}.programs.plasma.kwin.effects = {
    desktopSwitching = {
      animation = "slide";
      navigationWrapping = true;
    };

    dimAdminMode.enable = true;
    minimization.animation = "magiclamp";
    shakeCursor.enable = true;
    slideBack.enable = true;
    snapHelper.enable = true;
    wobblyWindows.enable = true;
  };
}
