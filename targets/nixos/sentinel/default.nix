{ flakeCfg, targetCfg, ... }:
let
  inherit (flakeCfg) fqdns;
  inherit (targetCfg) ports;
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

    caddy.virtualHosts.${fqdns.dns}.extraConfig = ''
      handle /dns-query* {
        reverse_proxy 127.0.0.1:${toString ports.adguard}
      }
      respond 404
    '';
  };

  sops.defaultSopsFile = ../../../secrets/dns.yaml;
}
