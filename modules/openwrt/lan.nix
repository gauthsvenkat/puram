{ hostCfg, ... }:
let
  inherit (hostCfg) lan;
in
{
  uci.settings = {
    network = {
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
          ip6assign = 60;
        };
      };
    };

    dhcp.dhcp.lan = {
      interface = "lan";
      start = 100;
      limit = 150;
      leasetime = "12h";
      dhcpv4 = "server";
      dhcpv6 = "server";
      ra = "server";
      ra_slaac = true;
      ra_flags = [
        "managed-config"
        "other-config"
      ];
    };
  };
}
