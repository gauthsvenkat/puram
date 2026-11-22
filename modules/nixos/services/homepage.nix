{ flakeCfg, targetCfg, ... }:
let
  inherit (flakeCfg) domains;
  inherit (targetCfg) ports;
in
{
  services.homepage-dashboard = {
    enable = true;
    allowedHosts = "homepage.${domains.apex}";
    listenPort = ports.homepage;
  };
}
