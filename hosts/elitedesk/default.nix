{ inputs, username, ... }:
{
  imports = [
    inputs.agenix.nixosModules.default
    ./disko-config.nix
    ./hardware-configuration.nix
    ../../common/boot.nix
    ../../common/zfs.nix
    ../../common/nix-settings.nix
    ../../common/system.nix
    ../../common/users.nix
    ../../common/home-manager
    ../../common/ssh.nix
  ];

  boot.zfs.extraPools = [ "dontdie" ];

  age.secrets.".env" = {
    owner = username;
    file = ./.env;
  };

  home-manager.users.${username}.programs.git = {
    userEmail = "gauthsvenkat@gmail.com";
  };
}
