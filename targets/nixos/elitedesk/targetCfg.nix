rec {
  hostname = "elitedesk";
  system = "x86_64-linux";
  username = "ando";
  homeDirectory = "/home/${username}";
  gitEmail = "gauthsvenkat@gmail.com";
  sshHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgbm/atBI4qLsSPhlb8pnA4BpMe2WetWXkomjNwoWIL root@elitedesk";

  zpool = "dontdie";
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
  addresses = {
    headnet = "100.64.0.2";
    lan = "192.168.20.3";
  };
  mac = "ac:e2:d3:14:d9:27";

  ports = {
    adguard = 3000;
    # Caddy hardcodes its admin API port; this only mirrors it.
    caddy-admin = 2019;
    homepage = 7575;
    immich = 2283;
    # `services.jellyfin` hardcodes this port; this only mirrors it.
    jellyfin = 8096;
    paperless = 8000;
    paperless-gotenberg = 3030;
    paperless-tika = 9998;
    vikunja = 3456;
    # BEGIN-PRIVATE
    bazarr = 6767;
    bitmagnet = 3333;
    bitmagnet-dht = 3334;
    flaresolverr = 8191;
    prowlarr = 9696;
    qbittorrent = 8082;
    # Set in the qBittorrent UI; listed only to show the port is taken.
    qbittorrent-bt = 6881;
    radarr = 7878;
    sabnzbd = 8083;
    seerr = 5055;
    sonarr = 8989;
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
