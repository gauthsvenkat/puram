{
  hostCfg,
  lib,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username;
  inherit (lib) getExe;
in
{
  home-manager.users.${username} =
    let
      pkg = pkgs.guake;
    in
    {
      home.packages = [ pkg ];

      # NOTE: Guake's binding is set this way as the F12 binding set in guake itself won't work.
      # See https://github.com/Guake/guake/issues/1642#issuecomment-536887428.
      dconf.settings =
        let
          path = "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0";
        in
        {
          "${path}" = {
            binding = "F12";
            name = "guake";
            command = getExe pkg;
          };

          "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [ "/${path}/" ];
        };

      xdg.autostart.entries = [
        "${pkg}/share/applications/guake.desktop"
      ];
    };
}
