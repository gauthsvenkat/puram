{
  hostCfg,
  ...
}:
let
  inherit (hostCfg) username;
in
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings.env = [
    "XCURSOR_SIZE,24"
    "HYPRCURSOR_SIZE,24"
  ];
}
