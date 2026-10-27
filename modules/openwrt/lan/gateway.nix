{ openwrtCfg, ... }:
let
  inherit (openwrtCfg) gateway;
in
{
  uci.settings.network.interface.lan = {
    inherit gateway;
    dns = [ gateway ];
  };
}
