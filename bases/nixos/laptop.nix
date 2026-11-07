{
  imports = [
    ../../modules/nixos/system/lid-switch.nix
    ../../modules/nixos/system/wifi.nix

    ../../modules/nixos/services/kanata.nix
    ../../modules/nixos/services/tailscale.nix
    ../../modules/nixos/services/tlp.nix

    ./workstation.nix
  ];
}
