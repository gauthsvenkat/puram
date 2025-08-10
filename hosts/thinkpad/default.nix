{
  imports = [
    ./hardware-configuration.nix

    ../../bases/laptop.nix
    ../../bases/personal.nix
    ../../bases/workstation-hyprland.nix

    ../../components/config.nix
    ../../components/extra/autologin.nix
  ];

  hostCfg = {
    hostname = "thinkpad";
    isLaptop = true;
  };
}
