{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    getExe
    getExe'
    mkOption
    types
    ;
  inherit (config.hostCfg) homeDirectory;
in
{
  options.hyprCfg = mkOption {
    type = types.attrs;
    readOnly = true;
  };

  config.hyprCfg = with pkgs; {
    brightnessctl = getExe brightnessctl;
    browser = getExe firefox;
    fileManager = getExe' kdePackages.dolphin "dolphin";
    launcher = "${getExe' tofi "tofi-drun"} --drun-launch=true";
    lockScreen = getExe hyprlock;
    playerctl = getExe playerctl;
    statusBar = getExe hyprpanel;
    wezterm = getExe wezterm;

    screenshot = ''
      ${getExe grimblast} save area - | \
      ${getExe satty} \
        --filename - \
        --initial-tool brush \
        --early-exit \
        --copy-command ${getExe' wl-clipboard "wl-copy"} \
        --output-filename ${homeDirectory}/Pictures/screenshots/screenshot-$(date +%Y%m%d_%H%M%S).png
    '';

    recorder = "${writeShellScript "wf-recorder-wrapper" ''
      # Ensure recordings directory exists
      RECORDINGS_DIR="${homeDirectory}/Videos/recordings"
      mkdir -p "$RECORDINGS_DIR"

      # Change to recordings directory and run wf-recorder
      cd "$RECORDINGS_DIR"
      exec ${getExe wf-recorder} \
        -f "recording-$(date +%Y%m%d_%H%M%S).mp4" \
        "$@"
    ''}";
  };
}
