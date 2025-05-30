{
  imports = [
    ./workstation.nix

    ../components/services/tlp.nix
    ../components/services/kanata.nix
  ];

  services.tailscale.enable = true;
}
