{ targetCfg, ... }:
let
  inherit (targetCfg) wunlock;
in
{
  uci.settings = {
    network = {
      device = [
        {
          name = "br-wunlock";
          type = "bridge";
        }
      ];

      interface."wunlock" = {
        device = "br-wunlock";
        proto = "static";
        ipaddr = [ "${wunlock.ip}/24" ];
      };
    };

    dhcp.dhcp."wunlock" = {
      interface = "wunlock";
      start = 100;
      limit = 150;
      leasetime = "5m";
    };

    wireless.wifi-iface."wunlock_radio1" = {
      device = "radio1"; # The 5 GHz radio.
      mode = "ap";
      network = "wunlock";
      inherit (wunlock) ssid;
      encryption = "psk2";
      key = wunlock.psk;
      hidden = true;
      isolate = true;
      disabled = false;
    };

    firewall = {
      zone = [
        {
          name = "wunlock";
          network = [ "wunlock" ];
          input = "REJECT";
          output = "REJECT";
          forward = "REJECT";
        }
      ];

      rule = [
        {
          name = "Allow-Wunlock-DHCP";
          src = "wunlock";
          proto = "udp";
          dest_port = 67;
          target = "ACCEPT";
        }
        {
          name = "Allow-Wunlock-DHCP-Reply";
          dest = "wunlock";
          proto = "udp";
          dest_port = 68;
          target = "ACCEPT";
        }
        {
          name = "Allow-Wunlock-Tang";
          src = "wunlock";
          proto = "tcp";
          dest_port = 9090;
          target = "ACCEPT";
        }
      ];
    };
  };
}
