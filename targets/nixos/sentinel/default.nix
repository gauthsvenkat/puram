{
  imports = [
    ../../../bases/nixos/oci.nix

    ../../../modules/nixos/services/adguard-home.nix
    ../../../modules/nixos/services/caddy.nix
    ../../../modules/nixos/services/headplane.nix
    ../../../modules/nixos/services/headscale.nix
    ../../../modules/nixos/services/litestream.nix
    ../../../modules/nixos/services/ntfy.nix
    ../../../modules/nixos/services/oauth2-proxy.nix
    ../../../modules/nixos/services/pocket-id.nix
    ../../../modules/nixos/services/tailscale.nix

    ./auth.nix
    ./backups.nix
    ./disko-config.nix
    ./dns.nix
    ./hardware-configuration.nix
    ./headnet.nix
    ./ntfy.nix
  ];
}
