{ username, ... }:
let
  zpool = "dontdie";
in
{
  imports = [

    ./disko-config.nix
    ./hardware-configuration.nix

    ../../common/boot.nix
    ../../common/system.nix
    ../../common/users.nix
    ../../common/nix-settings.nix

    ../../common/home-manager.nix

    ../../common/services/zfs.nix
  ];

  services = {
    openssh.enable = true;
    tailscale.enable = true;
  };

  boot.zfs.extraPools = [ zpool ];

  services.sanoid.datasets."${zpool}" = {
    recursive = true;
    process_children_only = true;
    use_template = [ "default" ];
  };

  home-manager.users.${username}.programs.git = {
    userEmail = "gauthsvenkat@gmail.com";
  };
}
