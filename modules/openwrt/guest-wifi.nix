{ hostCfg, ... }:
let
  inherit (hostCfg) guest;
in
{
  uci.settings = {
    network = {
      device = [
        {
          name = "br-guest";
          type = "bridge";
        }
      ];

      interface.guest = {
        device = "br-guest";
        proto = "static";
        ipaddr = [ "${guest.ip}/24" ];
      };
    };

    dhcp.dhcp.guest = {
      interface = "guest";
      start = 100;
      limit = 150;
      leasetime = "1h";
    };

    wireless.wifi-iface."guest_${guest.radio}" = {
      device = guest.radio;
      mode = "ap";
      network = "guest";
      ssid._secret = "guest_wifi_ssid";
      encryption = "psk2";
      key._secret = "guest_wifi_psk";
      # Guests cannot see each other.
      isolate = true;
      # Off by default; enable in LuCI when needed.
      disabled = true;
    };

    firewall = {
      zone = [
        {
          name = "guest";
          network = [ "guest" ];
          input = "REJECT";
          output = "ACCEPT";
          forward = "REJECT";
        }
      ];

      forwarding = [
        {
          src = "guest";
          dest = "wan";
        }
      ];

      # Guests may only ask the router for an address and for names.
      rule = [
        {
          name = "Allow-Guest-DHCP";
          src = "guest";
          proto = "udp";
          dest_port = 67;
          target = "ACCEPT";
        }
        {
          name = "Allow-Guest-DNS";
          src = "guest";
          proto = "tcpudp";
          dest_port = 53;
          target = "ACCEPT";
        }
      ];
    };
  };
}
