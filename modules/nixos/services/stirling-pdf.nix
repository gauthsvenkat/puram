{ hostCfg, ... }:
let
  inherit (hostCfg.ports.stirlingPdf) port;
in
{
  services.stirling-pdf = {
    enable = true;
    environment.SERVER_PORT = port;
  };

  # services.stirling-pdf does not expose openFirewall.
  networking.firewall.allowedTCPPorts = [ port ];
}
