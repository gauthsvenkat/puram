{
  config,
  lib,
  ...
}: let
  inherit (config.hostCfg) username isLaptop;
  inherit (lib) optionals;
in {
  home-manager.users.${username}.programs.hyprpanel = {
    enable = true;
    settings = {
      terminal = "wezterm";

      bar = {
        layouts = {
          "*" = {
            left = ["dashboard" "windowtitle" "media"];
            middle = ["workspaces"];
            right = ["systray" "volume" "network" "bluetooth"] ++ optionals isLaptop ["battery"] ++ ["clock" "notifications"];
          };
        };
        launcher.autoDetectIcon = true;
        media.show_active_only = true;
        battery.hideLabelWhenFull = true;
        clock.format = "%a %b %d  %R";
        notifications = {
          show_total = true;
          hideCountWhenZero = true;
        };
      };

      menus = {
        media.displayTime = true;
        clock.weather = {
          location = "delft";
          unit = "metric";
        };
        dashboard.shortcuts = {
          left = {
            shortcut1 = {
              icon = "󰈹";
              command = "firefox";
              tooltip = "Firefox";
            };
            shortcut2 = {
              icon = "";
              command = "";
              tooltip = "";
            };
            shortcut3 = {
              icon = "";
              command = "wezterm";
              tooltip = "Wezterm";
            };
            shortcut4 = {
              icon = "󱓞";
              command = "tofi-drun --drun-launch=true";
              tooltip = "Launch";
            };
          };
          right = {
            shortcut1 = {
              icon = "";
              command = "";
              tooltip = "";
            };
          };
        };
        power.lowBatteryNotification = true;
      };
    };
  };
}
