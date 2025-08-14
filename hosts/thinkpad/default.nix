{
  imports = [
    ../../bases/nixos/desktop-environment/hyprland.nix

    ../../bases/nixos/flavor/laptop.nix
    ../../bases/nixos/flavor/personal.nix

    ../../components/config.nix

    ../../components/nixos/extra/autologin.nix

    ./hardware-configuration.nix
  ];

  hostCfg = {
    hostname = "thinkpad";
    isLaptop = true;
  };
}
