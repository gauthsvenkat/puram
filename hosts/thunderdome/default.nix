{
  username,
  ...
}:
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

  boot.zfs.extraPools = [ "wombocombo" ];

  home-manager.users.${username} = {
    programs.git = {
      userEmail = "gauthsvenkat@gmail.com";
      userName = "Gautham Venkataraman";
    };
  };
}
