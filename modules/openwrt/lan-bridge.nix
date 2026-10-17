{ targetCfg, ... }:
let
  inherit (targetCfg) lan;
in
{
  uci.settings.network = {
    device = [
      {
        name = "br-lan";
        type = "bridge";
        inherit (lan) ports;
      }
    ];

    interface = {
      loopback = {
        device = "lo";
        proto = "static";
        ipaddr = [ "127.0.0.1/8" ];
      };

      lan = {
        device = "br-lan";
        proto = "static";
        ipaddr = [ "${lan.ip}/24" ];
      };
    };
  };
}
