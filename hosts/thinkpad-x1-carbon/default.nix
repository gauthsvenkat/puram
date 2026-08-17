{
  imports = [
    ../../bases/nixos/desktop-environment/niri.nix

    ../../bases/nixos/flavor/laptop.nix
    ../../bases/nixos/flavor/personal.nix

    ./disko-config.nix
    ./hardware-configuration.nix
  ];
}
