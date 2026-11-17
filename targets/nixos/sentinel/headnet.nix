{ flakeCfg, targetCfg, ... }:
let
  inherit (flakeCfg) fqdns;
  inherit (targetCfg) headnetPrefixes ports;
in
{
  services.caddy.virtualHosts = {
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
}
