{
  pkgs,
  username,
  ...
}:
{
  imports = [
    ./home-manager.nix
    ./gui.nix
    ./services/mullvad-vpn.nix
  ];

  home-manager = {
    users.${username} = {
      home.packages = with pkgs; [
        jellyfin-media-player
        localsend
        rpi-imager
      ];
      xdg.autostart.entries = [
        "${pkgs.mullvad-vpn}/share/applications/mullvad-vpn.desktop"
      ];
    };
  };
}
