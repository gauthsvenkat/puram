{ hostCfg, ... }:
let
  inherit (hostCfg) username;
in
{
  home-manager.users.${username}.programs.plasma = {
    spectacle.shortcuts.captureRectangularRegion = "Print";

    configFile."spectaclerc" = {
      General.clipboardGroup = "PostScreenshotCopyImage";
      ImageSave.translatedScreenshotsFolder = "Screenshots";
      VideoSave.translatedScreenshotsFolder = "Screenshots";
    };
  };
}
