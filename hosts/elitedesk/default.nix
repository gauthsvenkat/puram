{ username, ... }:
{
  imports = [
    ./disko-config.nix
    ./hardware-configuration.nix

    ../../common/boot.nix
    ../../common/nix-settings.nix
    ../../common/system.nix
    ../../common/users.nix
    ../../common/home-manager
    ../../common/ssh.nix

    ./services
  ];

  home-manager.users.${username}.programs.git = {
    userEmail = "gauthsvenkat@gmail.com";
  };

  # boot = {
  #   supportedFilesystems = [ "zfs" ];
  #   zfs = {
  #     # By default, following option is true for legacy reasons.
  #     forceImportRoot = false;
  #     extraPools = [ "dontdie" ];
  #   };
  # };

  # ZFS requires networking.hostId to be set
  # networking.hostId = "0c0ffee0";
}
