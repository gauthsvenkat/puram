{
  hostCfg,
  lib,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username;
in
{
  home-manager.users.${username} = {
    home.packages = with pkgs; [
      ffmpegthumbnailer
      file-roller
      loupe
      nautilus
      papers
      wdisplays
    ];

    gtk = {
      enable = true;
      iconTheme = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
      };
    };

    programs.niri.settings = {
      binds."Mod+E".action.spawn = lib.getExe pkgs.nautilus;

      cursor = {
        theme = "Adwaita";
        size = 24;
      };
    };
  };
}
