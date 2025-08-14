{
  imports = [
    ../../../components/nixos/services/kanata.nix
    ../../../components/nixos/services/tlp.nix

    ../workstation.nix
  ];

  services.tailscale.enable = true;
}
