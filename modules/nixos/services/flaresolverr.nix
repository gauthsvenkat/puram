{ hostCfg, ... }:
let
  inherit (hostCfg.ports.flaresolverr) port;
in
{
  services.flaresolverr = {
    enable = true;
    inherit port;
  };
}
