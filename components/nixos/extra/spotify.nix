{
  config,
  pkgs,
  ...
}: let
  inherit (config.hostCfg) username;
in {
  home-manager.users.${username} = {
    home.packages = [pkgs.spotify];

    #NOTE: disabling spotify autostart in favor of spotify-player
    # xdg.autostart.entries = [
    #   "${pkgs.spotify}/share/applications/spotify.desktop"
    # ];
  };
}
