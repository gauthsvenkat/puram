{
  username,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix

    ../../common/system.nix
    ../../common/users.nix
    ../../common/nix-settings.nix

    ../../common/home-manager.nix

    ../../common/services/ssh.nix
    ../../common/services/adguardhome.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };

  services.logind.lidSwitchExternalPower = "ignore";

  home-manager.users.${username}.programs.git = {
    userEmail = "gauthsvenkat@gmail.com";
  };
}
