{
  imports = [
    ../../../modules/common/tailscale.nix

    ../../../modules/nixos/services/kanata.nix
    ../../../modules/nixos/services/tlp.nix

    ../workstation.nix
  ];
}
