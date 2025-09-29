{
  config,
  hostCfg,
  lib,
  ...
}:
let
  inherit (hostCfg)
    isLaptop
    username
    ;
  inherit (config.hyprVars)
    browser
    fileManager
    launcher
    recorder
    screenshot
    wezterm
    ;
in
{
  #NOTE: upower is a dependency for hyprpanel
  services.upower.enable = true;

  home-manager.users.${username}.programs.hyprpanel = {
    enable = true;
    settings = {
      bar = {
        layouts = {
          "*" = {
            left = [
              "dashboard"
              "windowtitle"
              "media"
            ];
            middle = [ "workspaces" ];
            right = [
              "systray"
              "volume"
              "network"
              "bluetooth"
            ]
            ++ lib.optionals isLaptop [ "battery" ]
            ++ [
              "clock"
              "notifications"
            ];
          };
        };
        launcher.autoDetectIcon = true;
        media.show_active_only = true;
        battery.hideLabelWhenFull = true;
        clock.format = "%a %b %d  %H:%M:%S";
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
              command = wezterm;
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
              command = screenshot;
              tooltip = "Screenshot";
            };
            shortcut2 = {
              icon = "";
              #TODO: bluelight command
              command = "cd .";
              tooltip = "Bluelight Filter";
            };
            shortcut3 = {
              icon = "";
              command = recorder;
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
