{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;
  inherit (config.hostCfg) homeDirectory;
in
{
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

    brightnessctl = mkOption {
      type = types.str;
      default = lib.getExe pkgs.brightnessctl;
      description = "brightness control";
    };

    statusBar = mkOption {
      type = types.str;
      default = lib.getExe pkgs.hyprpanel;
      description = "status bar";
    };

    screenshot = mkOption {
      type = types.str;
      default = ''
        ${lib.getExe pkgs.grimblast} save area - | \
        ${lib.getExe pkgs.satty} \
          --filename - \
          --initial-tool brush \
          --early-exit \
          --copy-command ${lib.getExe' pkgs.wl-clipboard "wl-copy"} \
          --output-filename ${homeDirectory}/Pictures/screenshots/screenshot-$(date +%Y%m%d_%H%M%S).png
      '';
      description = "screenshot (with annotation)";
    };
  };
}
