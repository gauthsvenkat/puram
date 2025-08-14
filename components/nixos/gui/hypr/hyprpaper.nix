{config, ...}: let
  inherit (config.hostCfg) username homeDirectory wallpaper;
in {
  home-manager.users.${username}.services.hyprpaper = {
    enable = true;
    settings = let
      wallpaperPath = "${homeDirectory}/Pictures/wallpapers/${wallpaper}";
    in {
      preload = wallpaperPath;
      wallpaper = ",${wallpaperPath}";
    };
  };
}
