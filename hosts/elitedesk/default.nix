{ inputs, username, ... }:
let
  zpool = "dontdie";
in
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

  boot.zfs.extraPools = [ zpool ];

  age.secrets.".env" = {
    owner = username;
    file = ./.env;
  };

  services.sanoid.datasets."${zpool}" = {
    recursive = true;
    process_children_only = true;
    use_template = [ "default" ];
  };

  home-manager.users.${username}.programs.git = {
    userEmail = "gauthsvenkat@gmail.com";
  };
}
