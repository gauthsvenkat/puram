{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    getExe
    getExe'
    ;
  inherit (config.hostCfg) homeDirectory;
in
{
  options.hyprCfg = {
    launcher = mkOption {
      type = types.str;
      default = "${getExe' pkgs.tofi "tofi-drun"} --drun-launch=true";
      description = "application launcher";
    };

    lockScreen = mkOption {
      type = types.str;
      default = getExe pkgs.hyprlock;
      description = "lock screen";
    };

    playerctl = mkOption {
      type = types.str;
      default = getExe pkgs.playerctl;
      description = "media player";
    };

    brightnessctl = mkOption {
      type = types.str;
      default = getExe pkgs.brightnessctl;
      description = "brightness control";
    };

    statusBar = mkOption {
      type = types.str;
      default = getExe pkgs.hyprpanel;
      description = "status bar";
    };

    screenshot = mkOption {
      type = types.str;
      default = ''
        ${getExe pkgs.grimblast} save area - | \
        ${getExe pkgs.satty} \
          --filename - \
          --initial-tool brush \
          --early-exit \
          --copy-command ${getExe' pkgs.wl-clipboard "wl-copy"} \
          --output-filename ${homeDirectory}/Pictures/screenshots/screenshot-$(date +%Y%m%d_%H%M%S).png
      '';
      description = "screenshot (with annotation)";
    };
  };
}
