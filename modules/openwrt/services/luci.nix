{
  packages = [
    "luci"
    "luci-ssl"
  ];

  # Not managed by dewclaw; keep the web interface as is.
  uci.retain = [
    "luci"
    "rpcd"
    "uhttpd"
  ];
}
