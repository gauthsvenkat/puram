{ inputs, username, ... }:
{
  imports = [
    inputs.agenix.nixosModules.default

    ./disko-config.nix
    ./hardware-configuration.nix

    ../../common/boot.nix
    ../../common/system.nix
    ../../common/users.nix
    ../../common/nix-settings.nix

    ../../common/home-manager.nix

    ../../common/services/zfs.nix
    ../../common/services/ssh.nix
  ];

  boot.zfs.extraPools = [ "dontdie" ];

  age.secrets.".env" = {
    owner = username;
    file = ./.env;
  };

  services.sanoid = {
    enable = true;
    templates."default" = {
      autosnap = true;
      autoprune = true;
      hourly = 4;
      daily = 7;
      monthly = 1;
      yearly = 0;
    };
    datasets."dontdie" = {
      recursive = true;
      process_children_only = true;
      use_template = [ "default" ];
    };
  };

  home-manager.users.${username}.programs.git = {
    userEmail = "gauthsvenkat@gmail.com";
  };
}
