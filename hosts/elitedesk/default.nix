{
  config,
  pkgs,
  ...
}:
let
  inherit (config.hostCfg) username;
  zpool = "dontdie";
in
{
  imports = [
    ../../bases/nixos/flavor/server.nix

    ../../components/nixos/hardware/intel-transcoding.nix

    ../../components/nixos/services/boinc.nix
    ../../components/nixos/services/foldingathome.nix
    ../../components/nixos/services/sanoid.nix
    ../../components/nixos/services/zfs.nix

    ../host-configuration.nix

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
