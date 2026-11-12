{
  uci.settings = {
    network.interface.lan.ip6assign = 60;

    dhcp.dhcp.lan = {
      interface = "lan";
      dhcpv4 = "server";
      dhcpv6 = "server";
      leasetime = "12h";
      start = 100;
      limit = 150;
      ra = "server";
      ra_slaac = true;
      ra_flags = [
        "managed-config"
        "other-config"
      ];
    };
  };
}
