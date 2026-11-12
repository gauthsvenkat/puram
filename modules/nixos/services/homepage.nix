{ flakeCfg, targetCfg, ... }:
let
  inherit (flakeCfg) domain;
  inherit (targetCfg.ports) homepage;
in
{
  services.homepage-dashboard = {
    enable = true;
    allowedHosts = "homepage.${domain}";
    listenPort = homepage.port;
  };
}
