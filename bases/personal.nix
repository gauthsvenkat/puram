{ pkgs, username, ... }:
{
  imports = [
    ./workstation.nix

    ../components/optional/services/syncthing.nix
    ../components/optional/services/mullvad-vpn.nix
  ];

  home-manager.users.${username}.home.packages = with pkgs; [
    age
    jellyfin-media-player
    rpi-imager
    localsend
  ];
}
