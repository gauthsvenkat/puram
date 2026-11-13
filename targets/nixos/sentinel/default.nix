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
    ../../../modules/nixos/services/headscale.nix

    ./disko-config.nix
    ./hardware-configuration.nix
  ];

  services = {
    # Caddy terminates TLS, so AdGuard answers DoH over plain HTTP behind it.
    adguardhome.settings.http.doh.insecure_enabled = true;

    caddy.virtualHosts = {
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
    };
  };

  sops.defaultSopsFile = ../../../secrets/dns.yaml;
}
