{
  imports = [
    ./workstation.nix

    ../components/services/kanata.nix
    ../components/services/tlp.nix
  ];

  services.tailscale.enable = true;
}
