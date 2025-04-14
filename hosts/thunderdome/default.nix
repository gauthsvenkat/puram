{
  username,
  ...
}:
let
  zpool = "wombocombo";
in
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

    ../../common/services/syncthing.nix
    ../../common/services/zfs.nix
  ];

  boot.zfs.extraPools = [ zpool ];
  services.sanoid.datasets."${zpool}".use_template = [ "default" ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    graphics.enable = true;
    nvidia = {
      open = false;
      modesetting.enable = true;
    };
  };

  home-manager.users.${username}.programs.git.userEmail = "gauthsvenkat@gmail.com";
}
