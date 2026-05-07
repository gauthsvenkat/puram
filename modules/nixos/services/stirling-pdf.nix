{ hostCfg, ... }:
let
  inherit (hostCfg) domain;
  inherit (hostCfg.ports.stirlingPdf) port;
in
{
  services.stirling-pdf = {
    enable = true;
    environment.SERVER_PORT = port;
  };

  services.caddy.virtualHosts."stirling.${domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString port}
  '';

  # services.stirling-pdf does not expose openFirewall.
  networking.firewall.allowedTCPPorts = [ port ];
}
