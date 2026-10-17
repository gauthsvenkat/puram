{ pkgs, ... }:
{
  imports = [
    ../../../bases/nixos/laptop.nix
    ../../../bases/nixos/niri.nix
    ../../../bases/nixos/personal.nix

    ./disko-config.nix
    ./hardware-configuration.nix
    ./monitors.nix
  ];

  hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];

  services.thermald.enable = true;
}
