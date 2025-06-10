{
  pkgs,
  username,
  ...
}: {
  imports = [
    ./workstation.nix

    ../components/services/mullvad-vpn.nix
    ../components/services/syncthing.nix
  ];

  home-manager.users.${username}.home.packages = with pkgs; [
    age
    jellyfin-media-player
    localsend
    rpi-imager
  ];
}
