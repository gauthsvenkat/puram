{ targetCfg, ... }:
let
  inherit (targetCfg) ports;
in
{
  services.flaresolverr = {
    enable = true;
    port = ports.flaresolverr;
  };
}
