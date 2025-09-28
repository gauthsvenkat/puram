{ config, ... }:
let
  inherit (config.hostCfg) username wallpaper;
in
{
  home-manager.users.${username}.services.hyprpaper = {
    enable = true;
    settings = {
      preload = wallpaper;
      wallpaper = ",${wallpaper}";
    };
  };
}
