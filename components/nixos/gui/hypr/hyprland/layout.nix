{
  config,
  ...
}:
let
  inherit (config.hostCfg) username;
in
{
  home-manager.users.${username}.wayland.windowManager.hyprland.settings = {
    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };

    master.new_status = "master";
  };
}
