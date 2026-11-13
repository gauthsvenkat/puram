{
  flakeCfg,
  targetCfg,

  targetCfgs,

  ...
}:
let
  inherit (flakeCfg) controlServer;
  inherit (targetCfg) headscale;
  controlServerIp = targetCfgs.nixos.${controlServer}.addresses.lan;
in
{
  uci.settings = {
    network = {
      device = [
        {
          name = "br-headscale";
          type = "bridge";
          inherit (headscale) ports;
        }
      ];

      interface."headscale" = {
        device = "br-headscale";
        proto = "static";
        ipaddr = [ "${headscale.ip}/24" ];
      };
    };

    dhcp.dhcp."headscale" = {
      interface = "headscale";
      dynamicdhcp = false;
    };

    firewall = {
      zone = [
        {
          name = "headscale";
          network = [ "headscale" ];
          input = "REJECT";
          output = "REJECT";
          forward = "REJECT";
        }
      ];

      forwarding = [
        {
          src = "lan";
          dest = "headscale";
        }
        {
          src = "headscale";
          dest = "wan";
        }
      ];

      redirect = [
        {
          name = "Forward-Headscale-HTTPS";
          src = "wan";
          src_dport = 443;
          dest = "headscale";
          dest_ip = controlServerIp;
          dest_port = 443;
          proto = "tcp";
          target = "DNAT";
          limit = "1/second";
          limit_burst = 50;
          reflection_zone = [
            "headscale"
            "homelab"
            "lan"
          ];
        }
      ];

      rule = [
        {
          name = "Allow-Headscale-DHCP";
          src = "headscale";
          proto = "udp";
          dest_port = 67;
          target = "ACCEPT";
        }
        {
          name = "Allow-Headscale-DHCP-Reply";
          dest = "headscale";
          proto = "udp";
          dest_port = 68;
          target = "ACCEPT";
        }
        {
          name = "Allow-Headscale-DNS";
          src = "headscale";
          proto = "tcpudp";
          dest_port = 53;
          target = "ACCEPT";
        }
      ];
    };
  };
}
