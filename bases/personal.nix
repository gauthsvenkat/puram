{ pkgs, username, ... }:
{
  imports = [
    ./workstation.nix

    ../components/services/syncthing.nix
    ../components/services/mullvad-vpn.nix
  ];

  home-manager.users.${username}.home.packages = with pkgs; [
    age
    jellyfin-media-player
    rpi-imager
    localsend
  ];
}
