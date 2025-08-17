{
  imports = [
    ../../bases/nixos/desktop-environment/hyprland.nix

    ../../bases/nixos/flavor/laptop.nix
    ../../bases/nixos/flavor/personal.nix

    ../../components/variables.nix

    ./hardware-configuration.nix
  ];

  hostCfg.isLaptop = true;
}
