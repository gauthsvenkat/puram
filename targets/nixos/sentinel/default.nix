{ flakeCfg, targetCfg, ... }:
let
  inherit (flakeCfg) fqdns;
  inherit (targetCfg) headnetPrefixes ports;
in
{
  imports = [
    ../../../bases/nixos/oci.nix

    ../../../modules/nixos/services/adguard-home.nix
    ../../../modules/nixos/services/caddy.nix
    ../../../modules/nixos/services/headplane.nix
    ../../../modules/nixos/services/headscale.nix
    ../../../modules/nixos/services/tailscale.nix

    ./disko-config.nix
    ./hardware-configuration.nix
  ];

  services = {
    # Caddy terminates TLS, so AdGuard answers DoH over plain HTTP behind it.
    adguardhome.settings.http.doh.insecure_enabled = true;

    caddy.virtualHosts = {
      ${fqdns.adguard}.extraConfig = ''
        @headnet remote_ip ${headnetPrefixes.v4} ${headnetPrefixes.v6}
        handle @headnet {
          reverse_proxy 127.0.0.1:${toString ports.adguard}
        }
        respond 404
      '';
      ${fqdns.dns}.extraConfig = ''
        handle /dns-query* {
          reverse_proxy 127.0.0.1:${toString ports.adguard}
        }
        respond 404
      '';
      ${fqdns.headscale}.extraConfig = ''
        @headscale {
          # Control
          path /ts2021 /key /machine/ping-response
          # Login
          path /register/* /auth/*
          # Relay
          path /derp /derp/probe /derp/latency-check /bootstrap-dns
          # Monitoring
          path /health
          # Setup guides
          path /apple /apple/* /windows
          # Static
          path / /favicon.ico /robots.txt
        }
        handle @headscale {
          reverse_proxy 127.0.0.1:${toString ports.headscale}
        }
        respond 404
      '';
      ${fqdns.headplane}.extraConfig = ''
        @headnet remote_ip ${headnetPrefixes.v4} ${headnetPrefixes.v6}
        handle @headnet {
          redir / /admin/
          reverse_proxy 127.0.0.1:${toString ports.headplane}
        }
        respond 404
      '';
    };

    tailscale.extraSetFlags = [ "--accept-dns=false" ];
  };

  sops.defaultSopsFile = ../../../secrets/dns.yaml;
}
