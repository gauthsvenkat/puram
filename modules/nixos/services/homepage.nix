{ flakeCfg, targetCfg, ... }:
let
  inherit (flakeCfg) domain;
  inherit (targetCfg) ports;
in
{
  services.homepage-dashboard = {
    enable = true;
    allowedHosts = "homepage.${domain}";
    listenPort = ports.homepage;
  };
}
