{
  hostCfg,
  ...
}:
let
  inherit (hostCfg) username;
in
{
  home-manager.users.${username}.wayland.windowManager.hyprland = {
    settings = {
      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad.natural_scroll = true;
      };

      gestures.workspace_swipe = true;
    };

    extraConfig = ''
      monitor=,preferred,auto,auto
    '';
  };
}
