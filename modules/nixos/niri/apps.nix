{
  targetCfg,

  lib,
  pkgs,
  ...
}:
let
  inherit (targetCfg) username;
in
{
  services = {
    gvfs.enable = true;
    udisks2.enable = true;
  };

  home-manager.users.${username} = {
    gtk = {
      enable = true;
      iconTheme = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
      };
    };

    home.packages = with pkgs; [
      ffmpegthumbnailer
      file-roller
      loupe
      nautilus
      papers
      wdisplays
    ];

    programs.niri.settings = {
      binds."Mod+E".action.spawn = [
        (lib.getExe pkgs.wezterm)
        "start"
        "--"
        (lib.getExe pkgs.yazi)
      ];

      cursor = {
        theme = "Adwaita";
        size = 24;
      };
    };
  };
}
