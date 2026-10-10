{ hostCfg, ... }:
let
  inherit (hostCfg) lan;
in
{
  uci.settings.network.interface.lan = {
    inherit (lan) gateway;
    dns = [ lan.gateway ];
  };
}
