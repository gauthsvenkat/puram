{
  uci.settings.firewall = {
    defaults = [
      {
        input = "REJECT";
        output = "ACCEPT";
        forward = "REJECT";
        synflood_protect = true;
        flow_offloading = true;
      }
    ];

    zone = [
      {
        name = "lan";
        network = [ "lan" ];
        input = "ACCEPT";
        output = "ACCEPT";
        forward = "ACCEPT";
      }
      {
        name = "wan";
        network = [ "wan" ];
        input = "REJECT";
        output = "ACCEPT";
        forward = "DROP";
        masq = true;
        mtu_fix = true;
      }
    ];

    forwarding = [
      {
        src = "lan";
        dest = "wan";
      }
    ];

    # Stock OpenWrt rules: what the WAN side may send us. IPv6 stops working
    # without them.
    rule = [
      {
        name = "Allow-DHCPv6";
        src = "wan";
        proto = "udp";
        dest_port = 546;
        family = "ipv6";
        target = "ACCEPT";
      }
      {
        name = "Allow-MLD";
        src = "wan";
        proto = "icmp";
        src_ip = "fe80::/10";
        icmp_type = [
          "130/0"
          "131/0"
          "132/0"
          "143/0"
        ];
        family = "ipv6";
        target = "ACCEPT";
      }
      {
        name = "Allow-ICMPv6-Input";
        src = "wan";
        proto = "icmp";
        icmp_type = [
          "echo-reply"
          "destination-unreachable"
          "packet-too-big"
          "time-exceeded"
          "bad-header"
          "unknown-header-type"
          "router-solicitation"
          "neighbour-solicitation"
          "router-advertisement"
          "neighbour-advertisement"
        ];
        limit = "1000/sec";
        family = "ipv6";
        target = "ACCEPT";
      }
      {
        name = "Allow-ICMPv6-Forward";
        src = "wan";
        dest = "*";
        proto = "icmp";
        icmp_type = [
          "echo-request"
          "echo-reply"
          "destination-unreachable"
          "packet-too-big"
          "time-exceeded"
          "bad-header"
          "unknown-header-type"
        ];
        limit = "1000/sec";
        family = "ipv6";
        target = "ACCEPT";
      }
    ];
  };
}
