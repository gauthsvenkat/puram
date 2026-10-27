{ targetCfg, ... }:
let
  inherit (targetCfg) homelab;
in
{
  uci.settings = {
    network = {
      device = [
        {
          name = "br-homelab";
          type = "bridge";
          inherit (homelab) ports;
        }
      ];

      interface."homelab" = {
        device = "br-homelab";
        proto = "static";
        ipaddr = [ "${homelab.ip}/24" ];
      };
    };

    dhcp.dhcp."homelab" = {
      interface = "homelab";
      start = 100;
      limit = 150;
      leasetime = "12h";
    };

    firewall = {
      zone = [
        {
          name = "homelab";
          network = [ "homelab" ];
          input = "REJECT";
          output = "ACCEPT";
          forward = "REJECT";
        }
      ];

      forwarding = [
        {
          src = "homelab";
          dest = "wan";
        }
      ];

      # Servers may only ask the router for an address, for names, and for the tang key that unlocks their disks.
      rule = [
        {
          name = "Allow-Homelab-DHCP";
          src = "homelab";
          proto = "udp";
          dest_port = 67;
          target = "ACCEPT";
        }
        {
          name = "Allow-Homelab-DNS";
          src = "homelab";
          proto = "tcpudp";
          dest_port = 53;
          target = "ACCEPT";
        }
        {
          name = "Allow-Homelab-Tang";
          src = "homelab";
          proto = "tcp";
          dest_port = 9090;
          target = "ACCEPT";
        }
      ];
    };
  };
}
