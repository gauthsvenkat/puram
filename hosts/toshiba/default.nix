{ lib, ... }:
{
  imports = [
    ../../bases/nixos/flavor/server.nix

    ../../modules/nixos/services/adguardhome.nix

    ./hardware-configuration.nix
  ];

  boot.loader = {
    #NOTE: This system is so old systemd doesn't work.
    # Therefore, we use grub.
    systemd-boot.enable = lib.mkForce false;
    grub = {
      enable = true;
      device = "/dev/sda";
      useOSProber = true;
    };
  };

  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
}
