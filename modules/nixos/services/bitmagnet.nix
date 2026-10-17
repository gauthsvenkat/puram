{
  targetCfg,
  ...
}:
let
  inherit (targetCfg.ports.bitmagnet) port dht_port;
in
{
  services.bitmagnet = {
    enable = true;
    settings = {
      http_server.port = ":${toString port}";
      dht_server.port = dht_port;
      classifier.flags.delete_content_types = [
        "audiobook"
        "comic"
        "ebook"
        "game"
        "music"
        "software"
        "unknown"
        "xxx"
      ];
    };
  };

  # HACK: Force Go's pure-Go DNS resolver. The upstream module's sandbox
  # strips `AF_NETLINK`, which glibc's `getaddrinfo()` needs; pure-Go bypasses
  # libc and talks to the nameserver directly via `AF_INET`.
  systemd.services.bitmagnet.environment.GODEBUG = "netdns=go";
}
