{ hostCfg, ... }:
let
  inherit (hostCfg) username;
in
{
  home-manager.users.${username}.programs.niri.settings.window-rules = [
    {
      matches = [ { is-window-cast-target = true; } ];
      focus-ring = {
        active.color = "#f38ba8";
        inactive.color = "#7d0d2d";
      };
    }
    {
      clip-to-geometry = true;
      geometry-corner-radius = {
        bottom-left = 8.0;
        bottom-right = 8.0;
        top-left = 8.0;
        top-right = 8.0;
      };
    }
    {
      matches = [
        {
          app-id = "steam";
          title = "^notificationtoasts_\\d+_desktop$";
        }
      ];
      default-floating-position = {
        relative-to = "bottom-right";
        x = 10;
        y = 10;
      };
      open-focused = false;
    }
  ];
}
