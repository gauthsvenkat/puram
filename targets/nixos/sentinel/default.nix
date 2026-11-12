{
  flakeCfg,

  config,
  ...
}:
let
  inherit (flakeCfg) domain;
  cfg = config.services.adguardhome;
in
{
  imports = [
    ../../../bases/nixos/oci.nix

    ../../../modules/nixos/services/adguard-home.nix
    ../../../modules/nixos/services/caddy.nix

    ./disko-config.nix
    ./hardware-configuration.nix
  ];

  services = {
    # Caddy terminates TLS, so AdGuard answers DoH over plain HTTP behind it.
    adguardhome.settings.http.doh.insecure_enabled = true;

    caddy.virtualHosts."dns.${domain}".extraConfig = ''
      handle /dns-query* {
        reverse_proxy 127.0.0.1:${toString cfg.port}
      }
      respond 404
    '';
  };

  sops.defaultSopsFile = ../../../secrets/dns.yaml;
}
