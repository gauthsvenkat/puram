{ targetCfg, ... }:
let
  inherit (targetCfg) domain;
  inherit (targetCfg.ports) homepage;
in
{
  services.homepage-dashboard = {
    enable = true;
    listenPort = homepage.port;
    allowedHosts = "homepage.${domain}";
  };
}
