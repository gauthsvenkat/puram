{
  uci.settings.dhcp.odhcpd.odhcpd = {
    maindhcp = false;
    leasefile = "/tmp/odhcpd.leases";
    leasetrigger = "/usr/sbin/odhcpd-update";
    loglevel = 4;
    piodir = "/tmp/odhcpd-piodir";
    hostsdir = "/tmp/hosts";
  };
}
