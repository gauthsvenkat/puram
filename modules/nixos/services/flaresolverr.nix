{ targetCfg, ... }:
{
  services.flaresolverr = {
    enable = true;
    inherit (targetCfg.ports.flaresolverr) port;
  };
}
