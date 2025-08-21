{
  imports = [
    ../../bases/nixos/desktop-environment/hyprland.nix

    ../../bases/nixos/flavor/laptop.nix
    ../../bases/nixos/flavor/personal.nix

    ../../components/host-config.nix
    ../../components/nixos/gui/hypr/variables.nix

    ./hardware-configuration.nix
  ];

  hostCfg.isLaptop = true;
}
