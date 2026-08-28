{ lib, ... }:
{
  boot.loader = {
    systemd-boot = {
      enable = lib.mkDefault true;
      configurationLimit = 3;
    };
    efi.canTouchEfiVariables = true;
  };
}
