{ config, lib, ... }:
{
  boot.loader = {
    efi.canTouchEfiVariables = lib.mkDefault true;
    systemd-boot = {
      enable = lib.mkDefault true;
      configurationLimit = lib.mkDefault 3;
    };
    generic-extlinux-compatible = { inherit (config.boot.loader.systemd-boot) configurationLimit; };
  };
}
