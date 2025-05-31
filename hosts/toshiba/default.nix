{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../../bases/server.nix

    ../../components/services/adguardhome.nix
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

  services.logind.lidSwitchExternalPower = "ignore";
}
