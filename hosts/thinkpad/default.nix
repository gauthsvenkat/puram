{
  imports = [
    ../../bases/nixos/desktop-environment/hyprland.nix

    ../../bases/nixos/flavor/laptop.nix
    ../../bases/nixos/flavor/personal.nix

    ../../components/config.nix

    ./hardware-configuration.nix
  ];

  hostCfg.isLaptop = true;
}
