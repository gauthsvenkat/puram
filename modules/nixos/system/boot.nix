{ config, lib, ... }:
{
  boot.loader = {
    systemd-boot = {
      enable = lib.mkDefault true;
      configurationLimit = lib.mkDefault 3;
    };
    generic-extlinux-compatible.configurationLimit = config.boot.loader.systemd-boot.configurationLimit;
    efi.canTouchEfiVariables = lib.mkDefault true;
  };
}
