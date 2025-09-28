{
  imports = [
    ../../bases/nixos/desktop-environment/hyprland.nix

    ../../bases/nixos/flavor/laptop.nix
    ../../bases/nixos/flavor/personal.nix

    ../../modules/nixos/gui/hypr/variables.nix

    ../host-configuration.nix

    ./hardware-configuration.nix
  ];

  hostCfg.isLaptop = true;
}
