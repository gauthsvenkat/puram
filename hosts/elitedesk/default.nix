{
  hostCfg,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username;
  zpool = "dontdie";
in
{
  imports = [
    ../../bases/nixos/flavor/server.nix

    ../../modules/nixos/hardware/intel-transcoding.nix

    ../../modules/nixos/services/sanoid.nix
    ../../modules/nixos/services/zfs.nix

    ./disko-config.nix
    ./hardware-configuration.nix
  ];

  boot.zfs.extraPools = [ zpool ];

  services.sanoid.datasets."${zpool}" = {
    recursive = true;
    process_children_only = true;
    use_template = [ "default" ];
  };

  services.tailscale.enable = true;

  home-manager.users.${username}.home.packages = [ pkgs.age ];
}
