{
  imports = [
    ../../../modules/nixos/services/kanata.nix
    ../../../modules/nixos/services/tlp.nix

    ../workstation.nix
  ];

  services.tailscale.enable = true;
}
