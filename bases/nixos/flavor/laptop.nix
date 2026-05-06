{
  imports = [
    ../../../modules/nixos/services/kanata.nix
    ../../../modules/nixos/services/tailscale.nix
    ../../../modules/nixos/services/tlp.nix

    ../workstation.nix
  ];
}
