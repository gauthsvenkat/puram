{
  imports = [
    ./workstation.nix

    ../components/optional/services/tlp.nix
    ../components/optional/services/kanata.nix
  ];

  services.tailscale.enable = true;
}
