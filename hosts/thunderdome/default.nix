{
  username,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../common/boot.nix
    ../../common/nix-settings.nix
    ../../common/system.nix
    ../../common/users.nix
    ../../common/gui.nix
    ../../common/mullvad-vpn.nix
    ../../common/syncthing.nix
    ../../common/home-manager/personal.nix
    ../../common/home-manager/development.nix
  ];

  home-manager.users.${username} = {
    programs.git = {
      userEmail = "gauthsvenkat@gmail.com";
      userName = "Gautham Venkataraman";
    };
  };
}
