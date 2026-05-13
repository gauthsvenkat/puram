{ hostCfg, ... }:
let
  inherit (hostCfg) domain;
  inherit (hostCfg.ports) homepage;
in
{
  services.homepage-dashboard = {
    enable = true;
    listenPort = homepage.port;
    allowedHosts = "homepage.${domain}";
  };
}
