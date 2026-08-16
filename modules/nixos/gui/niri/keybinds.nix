{
  hostCfg,
  lib,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username;
in
{
  home-manager.users.${username} =
    { config, ... }:
    let
      inherit (config.lib.niri) actions;
      brightnessctl = lib.getExe pkgs.brightnessctl;
      wpctl = lib.getExe' pkgs.wireplumber "wpctl";
    in
    {
      programs.niri.settings.binds = {
        # apps
        "Mod+T".action = actions.spawn "wezterm";

        # window management
        "Alt+Tab".action = actions.focus-window-previous;
        "Mod+Q".action = actions.close-window;

        # focus: h/l between columns, j/k between workspaces
        "Mod+H".action = actions.focus-column-left;
        "Mod+J".action = actions.focus-window-or-workspace-down;
        "Mod+K".action = actions.focus-window-or-workspace-up;
        "Mod+L".action = actions.focus-column-right;

        # movement mirrors focus with shift
        "Mod+Shift+H".action = actions.move-column-left;
        "Mod+Shift+J".action = actions.move-column-to-workspace-down;
        "Mod+Shift+K".action = actions.move-column-to-workspace-up;
        "Mod+Shift+L".action = actions.move-column-right;

        # sizing
        "Mod+F".action = actions.maximize-column;
        "Mod+Shift+F".action = actions.fullscreen-window;
        "Mod+R".action = actions.switch-preset-column-width;
        "Mod+Shift+R".action = actions.switch-preset-window-height;
        "Mod+Minus".action.set-column-width = "-10%";
        "Mod+Equal".action.set-column-width = "+10%";
        "Mod+Shift+Minus".action.set-window-height = "-10%";
        "Mod+Shift+Equal".action.set-window-height = "+10%";

        # column operations
        "Mod+Comma".action = actions.consume-or-expel-window-left;
        "Mod+Period".action = actions.consume-or-expel-window-right;

        # overview / help
        "Mod+O".action = actions.toggle-overview;
        "Mod+Shift+Slash".action = actions.show-hotkey-overlay;

        # hardware keys
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action.spawn = [
            wpctl
            "set-volume"
            "@DEFAULT_AUDIO_SINK@"
            "5%-"
          ];
        };
        "XF86AudioMicMute" = {
          allow-when-locked = true;
          action.spawn = [
            wpctl
            "set-mute"
            "@DEFAULT_AUDIO_SOURCE@"
            "toggle"
          ];
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          action.spawn = [
            wpctl
            "set-mute"
            "@DEFAULT_AUDIO_SINK@"
            "toggle"
          ];
        };
        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action.spawn = [
            wpctl
            "set-volume"
            "-l"
            "1.0"
            "@DEFAULT_AUDIO_SINK@"
            "5%+"
          ];
        };
        "XF86MonBrightnessDown".action.spawn = [
          brightnessctl
          "set"
          "5%-"
        ];
        "XF86MonBrightnessUp".action.spawn = [
          brightnessctl
          "set"
          "5%+"
        ];

        # screencast
        "Mod+C".action = actions.set-dynamic-cast-window;
        "Mod+Ctrl+C".action = actions.clear-dynamic-cast-target;
        "Mod+Shift+C".action = actions.set-dynamic-cast-monitor;

        # session
        "Mod+Shift+Escape".action = actions.quit;
      };
    };
}
