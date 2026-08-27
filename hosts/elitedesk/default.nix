{
  hostCfg,
  ...
}:
let
  inherit (hostCfg) zpool;
in
{
  imports = [
    ../../bases/server.nix

    ../../modules/nixos/services/adguard-home.nix
    ../../modules/nixos/services/homepage.nix
    ../../modules/nixos/services/immich.nix
    ../../modules/nixos/services/jellyfin.nix
    ../../modules/nixos/services/paperless-ngx.nix
    ../../modules/nixos/services/postgresql.nix
    ../../modules/nixos/services/speedtest-tracker.nix
    ../../modules/nixos/services/tailscale.nix
    ../../modules/nixos/services/vikunja.nix
    ../../modules/nixos/services/zfs.nix

    ./backups.nix
    ./dashboard.nix
    ./disko-config.nix
    ./hardware-acceleration.nix
    ./hardware-configuration.nix
    ./media-permissions.nix
    ./reverse-proxy.nix
    ./zfs-encryption.nix
    ./zfs-snapshots.nix
  ];

  boot.zfs.extraPools = [ zpool ];

  sops.defaultSopsFile = ../../secrets/homeserver.yaml;
}
