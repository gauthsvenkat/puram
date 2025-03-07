{
  pkgs,
  username,
  ...
}:
{
  imports = [
    # TODO: Disko?
    ./hardware-configuration.nix
    ../../common/boot.nix
    ../../common/nix-settings.nix
    ../../common/system.nix
    ../../common/users.nix
    ../../common/gui.nix
    ../../common/kanata.nix
    ../../common/laptop.nix
    ../../common/ssh.nix
    ../../common/home-manager/personal.nix
    ../../common/home-manager/development.nix
  ];

  services = {
    mullvad-vpn = {
      enable = true;
      # pkgs.mullvad only contains the cli
      # while pkgs.mullvad-vpn comes with the gui as well
      package = pkgs.mullvad-vpn;
    };
  };

  home-manager.users.${username}.programs.git = {
    userEmail = "gauthsvenkat@gmail.com";
    userName = "Gautham Venkataraman";
  };
}
