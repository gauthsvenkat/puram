rec {
  hostname = "elitedesk";
  system = "x86_64-linux";
  username = "ando";
  homeDirectory = "/home/${username}";
  gitEmail = "gauthsvenkat@gmail.com";
  sshHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgbm/atBI4qLsSPhlb8pnA4BpMe2WetWXkomjNwoWIL root@elitedesk";

  zpool = "dontdie";
  domain = "gauthsvenkat.dev";
  tailnetIp = "100.103.236.120";
  paths = rec {
    config = "/var/lib";
    postgres = "${config}/postgresql";
    backups = "/${zpool}/services/backups";
    data = "/${zpool}/data";
    # BEGIN-PRIVATE
    entertainment = "${data}/entertainment";
    torrents = "${entertainment}/torrents";
    usenet = "${entertainment}/usenet";
    # END-PRIVATE
  };

  ports = {
    adguard = {
      dns_port = 53;
      web_port = 3000;
    };
    # BEGIN-PRIVATE
    bazarr.port = 6767;
    bitmagnet = {
      port = 3333;
      dht_port = 3334;
    };
    # END-PRIVATE
    # Caddy hardcodes its admin API port; this only mirrors it.
    caddy.admin_port = 2019;
    # BEGIN-PRIVATE
    flaresolverr.port = 8191;
    # END-PRIVATE
    homepage.port = 7575;
    immich.port = 2283;
    # `services.jellyfin` hardcodes this port; this only mirrors it.
    jellyfin.port = 8096;
    paperless = {
      port = 8000;
      gotenberg_port = 3030;
      tika_port = 9998;
    };
    # BEGIN-PRIVATE
    prowlarr.port = 9696;
    qbittorrent = {
      port = 8082;
      bt_port = 6881;
    };
    radarr.port = 7878;
    sabnzbd.port = 8083;
    seerr.port = 5055;
    sonarr.port = 8989;
    # END-PRIVATE
    vikunja.port = 3456;
  };
# BEGIN-PRIVATE

  vpn = {
    namespace = "wg";
    bridgeAddress = "192.168.15.5";
    namespaceAddress = "192.168.15.1";
  };
# END-PRIVATE
}
