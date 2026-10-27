{
  inputs,

  targetCfg,

  lib,
  pkgs,
  ...
}:
let
  inherit (targetCfg) username wallpaper;
in
{
  home-manager.users.${username} =
    { config, ... }:
    let
      noctalia = lib.getExe config.programs.noctalia.package;
    in
    {
      imports = [ inputs.noctalia.homeModules.default ];

      programs.noctalia = {
        enable = true;
        settings = {
          bar.default = {
            background_opacity = 0.0;
            capsule_group = [
              {
                id = "left-of-center";
                members = [
                  "launcher"
                  "clock"
                ];
              }
              {
                id = "right-of-center";
                members = [
                  "date"
                  "control-center"
                ];
              }
              {
                id = "session";
                members = [
                  "session"
                  "settings"
                ];
              }
              {
                id = "status";
                members = [
                  "privacy"
                  "notifications"
                  "clipboard"
                  "network"
                  "bluetooth"
                  "volume"
                  "brightness"
                  "battery"
                ];
              }
            ];
            dead_zone.actions.left = "exec ${lib.getExe pkgs.niri} msg action toggle-overview";
            start = [ "group:session" ];
            center = [
              "group:left-of-center"
              "workspaces"
              "group:right-of-center"
            ];
            end = [
              "tray"
              "group:status"
            ];
            scale = 1.25;
          };

          battery.warning_threshold = 25;

          idle = {
            pre_action_fade_seconds = 2.0;
            behavior = {
              lock = {
                action = "lock";
                enabled = true;
                timeout = 600;
              };
              # Counts from the lock, not from idle start.
              screen-off = {
                action = "screen_off";
                enabled = true;
                timeout = 3600;
              };
            };
          };

          location = {
            latitude = 52.0116;
            longitude = 4.3571;
          };

          lockscreen.transition_duration = 500;

          nightlight.enabled = true;

          shell.lang = "en";

          theme = {
            mode = "dark";
            pure_black_dark = true;
            source = "wallpaper";
            wallpaper_scheme = "vibrant";
          };

          wallpaper.directory = lib.dirOf wallpaper;

          widget = {
            battery = {
              hide_when_plugged = false;
              show_label = false;
            };
            brightness.show_label = false;
            clock.format = "{:%H:%M:%S}";
            network.show_label = false;
            volume.show_label = false;
            workspaces = {
              active_pill_size = 2.0;
              anchor = true;
              hide_when_empty = true;
              show_labels = false;
            };
          };
        };
      };

      programs.niri.settings = {
        binds = {
          "Mod+Escape".action.spawn-sh = "${noctalia} msg session lock";
          "Mod+Return".action.spawn-sh = "${noctalia} msg panel-toggle launcher";
          "Mod+S".action.spawn-sh = "${noctalia} msg panel-toggle control-center";

          "XF86AudioNext" = {
            allow-when-locked = true;
            action.spawn-sh = "${noctalia} msg media next";
          };
          "XF86AudioPlay" = {
            allow-when-locked = true;
            action.spawn-sh = "${noctalia} msg media toggle";
          };
          "XF86AudioPrev" = {
            allow-when-locked = true;
            action.spawn-sh = "${noctalia} msg media previous";
          };
        };

        # niri drops xdg-activation tokens with invalid serials as focus-steal
        # protection; honoring them lets notification/tray clicks focus apps
        debug.honor-xdg-activation-with-invalid-serial = [ ];

        # keep the wallpaper stationary behind transparent workspaces
        layer-rules = [
          {
            matches = [ { namespace = "^noctalia-wallpaper"; } ];
            place-within-backdrop = true;
          }
        ];

        layout.background-color = "transparent";

        overview.workspace-shadow.enable = false;

        spawn-at-startup = [ { argv = [ noctalia ]; } ];

        # float the noctalia settings window instead of tiling it
        window-rules = [
          {
            matches = [ { app-id = "dev.noctalia.Noctalia"; } ];
            default-column-width.fixed = 1080;
            default-window-height.fixed = 920;
            open-floating = true;
          }
        ];
      };
    };
}
