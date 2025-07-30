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
      default = "${pkgs.tofi}/bin/tofi-drun --drun-launch=true";
      description = "application launcher";
    };

    lockScreen = mkOption {
      type = types.str;
      default = "${pkgs.hyprlock}/bin/hyprlock";
      description = "lock screen command";
    };

    playerctl = mkOption {
      type = types.str;
      default = "${pkgs.playerctl}/bin/playerctl";
      description = "media player";
    };
  };
}
