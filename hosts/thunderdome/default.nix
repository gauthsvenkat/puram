{
  username,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../common/boot.nix
    ../../common/zfs.nix
    ../../common/nix-settings.nix
    ../../common/system.nix
    ../../common/users.nix
    ../../common/gui.nix
    ../../common/mullvad-vpn.nix
    ../../common/syncthing.nix
    ../../common/home-manager/personal.nix
    ../../common/home-manager/development.nix
  ];

  boot.zfs.extraPools = [ "wombocombo" ];

  home-manager.users.${username} = {
    programs.git = {
      userEmail = "gauthsvenkat@gmail.com";
      userName = "Gautham Venkataraman";
    };
  };
}
