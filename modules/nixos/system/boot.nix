{ lib, ... }:
{
  boot.loader = {
    systemd-boot = {
      enable = lib.mkDefault true;
      configurationLimit = lib.mkDefault 3;
    };
    efi.canTouchEfiVariables = lib.mkDefault true;
  };
}
