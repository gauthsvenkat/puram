{
  imports = [
    ../../modules/nixos/system/wifi.nix

    ../../modules/nixos/services/kanata.nix
    ../../modules/nixos/services/tailscale.nix
    ../../modules/nixos/services/tlp.nix

    ./workstation.nix
  ];

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
  };
}
