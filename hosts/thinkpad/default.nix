{
  imports = [
    ./hardware-configuration.nix

    ../../bases/laptop.nix
    ../../bases/personal.nix
    ../../bases/workstation-kde.nix
    ../../bases/workstation-hyprland.nix

    ../../components/config.nix
  ];

  hostCfg = {
    hostname = "thinkpad";
    isLaptop = true;
  };
}
