{
  imports = [
    ./hardware-configuration.nix

    ../../common/boot.nix
    ../../common/system.nix
    ../../common/users.nix
    ../../common/nix-settings.nix
    ../../common/gui.nix

    ../../common/personal.nix
    ../../common/development.nix
    ../../common/laptop.nix

    ../../common/services/syncthing.nix
    ../../common/services/kanata.nix
  ];

  services.tailscale.enable = true;
}
