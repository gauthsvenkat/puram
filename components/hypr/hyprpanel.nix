{
  config,
  lib,
  ...
}: let
  inherit (config.hostCfg) username isLaptop terminal browser fileManager;
  inherit (config.hyprCfg) launcher;
in {
  home-manager.users.${username}.programs.hyprpanel = {
    enable = true;
    settings = {
      bar = {
        layouts = {
          "*" = {
            left = ["dashboard" "windowtitle" "media"];
            middle = ["workspaces"];
            right =
              ["systray" "volume" "network" "bluetooth"]
              ++ lib.optionals isLaptop ["battery"]
              ++ ["clock" "notifications"];
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
        clock = {
          time.military = true;
          weather.enabled = false;
        };
        dashboard.shortcuts = {
          left = {
            shortcut1 = {
              icon = "";
              command = terminal;
              tooltip = "Terminal";
            };
            shortcut2 = {
              icon = "";
              command = fileManager;
              tooltip = "File Manager";
            };
            shortcut3 = {
              icon = "";
              command = browser;
              tooltip = "Browser";
            };
            shortcut4 = {
              icon = "󱓞";
              command = launcher;
              tooltip = "Launcher";
            };
          };
          right = {
            shortcut1 = {
              icon = "";
              #TODO: Screenshot command
              command = "";
              tooltip = "Screenshot";
            };
            shortcut2 = {
              icon = "";
              #TODO: bluelight command
              command = "";
              tooltip = "Bluelight Filter";
            };
            shortcut3 = {
              icon = "";
              #TODO: record command
              command = "";
              tooltip = "Record screen";
            };
            shortcut4 = {
              icon = "";
              command = "hyprpanel toggleWindow settings-dialog";
              tooltip = "HyprPanel Configuration";
            };
          };
        };
        power.lowBatteryNotification = true;
      };

      theme.bar.transparent = true;
    };
  };
}
