{
  imports = [
    ../../../modules/common/extra/personal.nix

    ../../../modules/nixos/services/mullvad-vpn.nix
    ../../../modules/nixos/services/syncthing.nix

    ../workstation.nix
  ];
}
