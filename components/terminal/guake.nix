{
  config,
  pkgs,
  ...
}: let
  inherit (config.hostCfg) username;
in {
  home-manager.users.${username} = {
    home.packages = [pkgs.guake];

    # NOTE: Guake's binding is set this way as the F12 binding set in guake itself won't work.
    # See https://github.com/Guake/guake/issues/1642#issuecomment-536887428.
    dconf.settings = let
      path = "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0";
    in {
      "${path}" = {
        binding = "F12";
        name = "guake";
        command = "${pkgs.guake}/bin/guake";
      };

      "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = ["/${path}/"];
    };

    xdg.autostart.entries = [
      "${pkgs.guake}/share/applications/guake.desktop"
    ];
  };
}
