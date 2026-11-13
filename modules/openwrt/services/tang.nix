{ targetCfg, ... }:
let
  inherit (targetCfg) ports;
in
{
  packages = [ "tang" ];

  uci.settings.tang.tang.config = {
    enabled = true;
    port = ports.tang;
  };
}
