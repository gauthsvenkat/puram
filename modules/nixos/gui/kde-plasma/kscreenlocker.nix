{ hostCfg, ... }:
let
  inherit (hostCfg) username;
in
{
  home-manager.users.${username}.programs.plasma.kscreenlocker = {
    appearance = {
      alwaysShowClock = true;
      showMediaControls = true;
      wallpaperPictureOfTheDay.provider = "bing";
    };

    autoLock = true;
    lockOnResume = true;
    timeout = 15; # minutes
  };
}
