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
  services.upower.enable = true;

  home-manager.users.${username} =
    { config, ... }:
    let
      noctalia = lib.getExe config.programs.noctalia.package;
    in
    {
      imports = [ inputs.noctalia.homeModules.default ];

      programs = {
        noctalia = {
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
              behavior = {
                lock = {
                  enabled = true;
                  action = "lock";
                  timeout = 600;
                };
                # Counts from the lock, not from idle start.
                screen-off = {
                  enabled = true;
                  action = "screen_off";
                  timeout = 3600;
                };
              };
              pre_action_fade_seconds = 2.0;
            };

            location = {
              latitude = 52.0116;
              longitude = 4.3571;
            };

            lockscreen.transition_duration = 500;

            nightlight.enabled = true;

            shell.lang = "en";

            wallpaper.directory = lib.dirOf wallpaper;

            theme = {
              mode = "dark";
              pure_black_dark = true;
              source = "wallpaper";
              wallpaper_scheme = "vibrant";
            };

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

        niri.settings = {
          spawn-at-startup = [ { argv = [ noctalia ]; } ];

          binds = {
            "Mod+Escape".action.spawn-sh = "${noctalia} msg session lock";
            "Mod+Return".action.spawn-sh = "${noctalia} msg panel-toggle launcher";
            "Mod+S".action.spawn-sh = "${noctalia} msg panel-toggle control-center";

            "XF86AudioNext" = {
              action.spawn-sh = "${noctalia} msg media next";
              allow-when-locked = true;
            };
            "XF86AudioPlay" = {
              action.spawn-sh = "${noctalia} msg media toggle";
              allow-when-locked = true;
            };
            "XF86AudioPrev" = {
              action.spawn-sh = "${noctalia} msg media previous";
              allow-when-locked = true;
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
    };
}
