{ targetCfg, ... }:
let
  inherit (targetCfg) iot;
in
{
  uci.settings = {
    network = {
      device = [
        {
          name = "br-iot";
          type = "bridge";
        }
      ];

      interface."iot" = {
        device = "br-iot";
        proto = "static";
        ipaddr = [ "${iot.ip}/24" ];
      };
    };

    dhcp.dhcp."iot" = {
      interface = "iot";
      leasetime = "12h";
      start = 100;
      limit = 150;
    };

    firewall = {
      zone = [
        {
          name = "iot";
          network = [ "iot" ];
          input = "REJECT";
          output = "ACCEPT";
          forward = "REJECT";
        }
      ];

      forwarding = [
        {
          src = "iot";
          dest = "wan";
        }
      ];

      # IoT devices may only ask the router for an address and for names.
      rule = [
        {
          name = "Allow-IoT-DHCP";
          src = "iot";
          proto = "udp";
          dest_port = 67;
          target = "ACCEPT";
        }
        {
          name = "Allow-IoT-DNS";
          src = "iot";
          proto = "tcpudp";
          dest_port = 53;
          target = "ACCEPT";
        }
      ];
    };

    wireless.wifi-iface."iot_radio0" = {
      disabled = false;
      device = "radio0"; # The 2.4 GHz radio.
      mode = "ap";
      network = "iot";
      ssid._secret = "iot_wifi_ssid";
      # Many IoT devices cannot join a WPA3 network.
      encryption = "psk2";
      key._secret = "iot_wifi_psk";
      isolate = true;
    };
  };
}
