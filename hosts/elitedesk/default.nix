{
  hostCfg,
  ...
}:
let
  inherit (hostCfg) paths zpool;
in
{
  imports = [
    ../../bases/nixos/flavor/server.nix

    ../../modules/common/tailscale.nix

    ../../modules/nixos/services/adguard-home.nix
    ../../modules/nixos/services/homepage.nix
    ../../modules/nixos/services/immich.nix
    ../../modules/nixos/services/jellyfin.nix
    ../../modules/nixos/services/paperless-ngx.nix
    ../../modules/nixos/services/speedtest-tracker.nix
    ../../modules/nixos/services/zfs.nix

    ./bind-mounts.nix
    ./dashboard.nix
    ./disko-config.nix
    ./hardware-acceleration.nix
    ./hardware-configuration.nix
    ./media-permissions.nix
    ./reverse-proxy.nix
    ./zfs-snapshots.nix
  ];

  boot.zfs.extraPools = [ zpool ];

  # Shared by every service that opts to use postgresql (paperless, immich, ...).
  services.postgresql.dataDir = paths.postgres;
}
