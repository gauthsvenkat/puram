{ targetCfg, ... }:
let
  inherit (targetCfg) lan;
in
{
  uci.settings.network.interface.lan = {
    inherit (lan) gateway;
    dns = [ lan.gateway ];
  };
}
