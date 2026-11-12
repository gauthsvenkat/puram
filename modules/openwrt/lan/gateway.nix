{ openwrtCfg, ... }:
let
  inherit (openwrtCfg) gateway;
in
{
  uci.settings.network.interface.lan = {
    dns = [ gateway ];
    inherit gateway;
  };
}
