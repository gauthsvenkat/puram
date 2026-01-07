{
  imports = [
    ../../bases/nixos/desktop-environment/kde.nix

    ../../bases/nixos/flavor/laptop.nix
    ../../bases/nixos/flavor/personal.nix

    ./hardware-configuration.nix
  ];
}
