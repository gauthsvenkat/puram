{
  pkgs,
  username,
  ...
}:
{
  imports = [ ./default.nix ];

  home-manager = {
    users.${username} = {
      home.packages = with pkgs; [
        jellyfin-media-player
        mpv
        localsend
      ];
      xdg.autostart.entries = [
        "${pkgs.mullvad-vpn}/share/applications/mullvad-vpn.desktop"
      ];
    };
  };
}
