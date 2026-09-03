{ pkgs, ... }:
{
  imports = [
    ../../bases/laptop.nix
    ../../bases/niri.nix
    ../../bases/personal.nix

    ./disko-config.nix
    ./hardware-configuration.nix
    ./monitors.nix
  ];

  hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];

  services.thermald.enable = true;
}
