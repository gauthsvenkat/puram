{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options.hyprCfg = {
    launcher = mkOption {
      type = types.str;
      default = "${lib.getExe' pkgs.tofi "tofi-drun"} --drun-launch=true";
      description = "application launcher";
    };

    lockScreen = mkOption {
      type = types.str;
      default = lib.getExe pkgs.hyprlock;
      description = "lock screen";
    };

    playerctl = mkOption {
      type = types.str;
      default = lib.getExe pkgs.playerctl;
      description = "media player";
    };

    statusBar = mkOption {
      type = types.str;
      default = "hyprpanel";
      description = "status bar";
    };
  };
}
