{
  targetCfg,
  ...
}:
let
  inherit (targetCfg) zpool;
in
{
  imports = [
    ../../../bases/nixos/server.nix

    ../../../modules/nixos/services/adguard-home.nix
    ../../../modules/nixos/services/homepage.nix
    ../../../modules/nixos/services/immich.nix
    ../../../modules/nixos/services/jellyfin.nix
    ../../../modules/nixos/services/paperless-ngx.nix
    ../../../modules/nixos/services/postgresql.nix
    ../../../modules/nixos/services/speedtest-tracker.nix
    ../../../modules/nixos/services/tailscale.nix
    ../../../modules/nixos/services/vikunja.nix
    ../../../modules/nixos/services/zfs.nix

    ./backups.nix
    ./dashboard.nix
    ./disko-config.nix
    ./hardware-acceleration.nix
    ./hardware-configuration.nix
    ./media-permissions.nix
    ./reverse-proxy.nix
    ./zfs-encryption.nix
    ./zfs-snapshots.nix
    # BEGIN-PRIVATE
    ../../../modules/nixos/services/bazarr.nix
    ../../../modules/nixos/services/bitmagnet.nix
    ../../../modules/nixos/services/flaresolverr.nix
    ../../../modules/nixos/services/prowlarr.nix
    ../../../modules/nixos/services/qbittorrent.nix
    ../../../modules/nixos/services/radarr.nix
    ../../../modules/nixos/services/recyclarr.nix
    ../../../modules/nixos/services/sabnzbd.nix
    ../../../modules/nixos/services/seerr.nix
    ../../../modules/nixos/services/sonarr.nix
    ./vpn.nix
    # END-PRIVATE
  ];

  boot.zfs.extraPools = [ zpool ];

  sops.defaultSopsFile = ../../../secrets/homeserver.yaml;
}
