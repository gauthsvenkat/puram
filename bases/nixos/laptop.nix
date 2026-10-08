{
  imports = [
    ../../modules/nixos/services/kanata.nix
    ../../modules/nixos/services/tailscale.nix
    ../../modules/nixos/services/tlp.nix

    ./workstation.nix
  ];

  services = {
    fprintd.enable = true;

    logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "ignore";
    };
  };
}
