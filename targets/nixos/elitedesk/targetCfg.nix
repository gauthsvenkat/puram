rec {
  hostname = "elitedesk";
  system = "x86_64-linux";
  username = "ando";
  homeDirectory = "/home/${username}";
  gitEmail = "gauthsvenkat@gmail.com";
  sshHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgbm/atBI4qLsSPhlb8pnA4BpMe2WetWXkomjNwoWIL root@elitedesk";

  zpool = "dontdie";
  offsiteBucket = "elitedesk-backup";
  paths = rec {
    backups = "/${zpool}/services/backups";
    config = "/var/lib";
    data = "/${zpool}/data";
    postgres = "${config}/postgresql";
    # BEGIN-PRIVATE
    entertainment = "${data}/entertainment";
    torrents = "${entertainment}/torrents";
    usenet = "${entertainment}/usenet";
    # END-PRIVATE
  };
  staticLease = {
    ip = "192.168.20.3";
    mac = "ac:e2:d3:14:d9:27";
  };
  tailnetIp = "100.64.0.2";

  ports = {
    adguard.port = 3000;
    # Caddy hardcodes its admin API port; this only mirrors it.
    caddy.admin_port = 2019;
    homepage.port = 7575;
    immich.port = 2283;
    # `services.jellyfin` hardcodes this port; this only mirrors it.
    jellyfin.port = 8096;
    paperless = {
      gotenberg_port = 3030;
      tika_port = 9998;
      port = 8000;
    };
    vikunja.port = 3456;
    # BEGIN-PRIVATE
    bazarr.port = 6767;
    bitmagnet = {
      dht_port = 3334;
      port = 3333;
    };
    flaresolverr.port = 8191;
    prowlarr.port = 9696;
    qbittorrent = {
      bt_port = 6881;
      port = 8082;
    };
    radarr.port = 7878;
    sabnzbd.port = 8083;
    seerr.port = 5055;
    sonarr.port = 8989;
    # END-PRIVATE
  };
  # BEGIN-PRIVATE
  # Loopback does not cross the namespace: host to confined service uses `namespaceAddress`,
  # confined service to host uses `bridgeAddress`.
  vpn = {
    namespace = "wg";
    bridgeAddress = "192.168.15.5";
    namespaceAddress = "192.168.15.1";
  };
  # END-PRIVATE
}
