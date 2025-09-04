{
  config,
  pkgs,
  ...
}:
let
  inherit (config.hostCfg) username;
in
{
  imports = [
    ../../../components/nixos/services/mullvad-vpn.nix
    ../../../components/nixos/services/syncthing.nix

    ../workstation.nix
  ];

  home-manager.users.${username}.home.packages = with pkgs; [
    age
    localsend
    rpi-imager
  ];
}
