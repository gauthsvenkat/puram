{
  imports = [
    ../../../components/common/extra/personal.nix

    ../../../components/nixos/services/mullvad-vpn.nix
    ../../../components/nixos/services/syncthing.nix

    ../workstation.nix
  ];
}
