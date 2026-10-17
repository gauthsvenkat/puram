{ targetCfg, ... }:
let
  inherit (targetCfg.ports.flaresolverr) port;
in
{
  services.flaresolverr = {
    enable = true;
    inherit port;
  };
}
