{ targetCfg, ... }:
let
  inherit (targetCfg) username;
in
{
  home-manager.users.${username}.programs.plasma = {
    configFile."spectaclerc" = {
      General.clipboardGroup = "PostScreenshotCopyImage";
      ImageSave.translatedScreenshotsFolder = "Screenshots";
      VideoSave.translatedScreenshotsFolder = "Screenshots";
    };

    spectacle.shortcuts.captureRectangularRegion = "Print";
  };
}
