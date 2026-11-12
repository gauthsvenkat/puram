{
  uci.settings.dhcp.odhcpd.odhcpd = {
    maindhcp = false;
    hostsdir = "/tmp/hosts";
    leasefile = "/tmp/odhcpd.leases";
    leasetrigger = "/usr/sbin/odhcpd-update";
    loglevel = 4;
    piodir = "/tmp/odhcpd-piodir";
  };
}
