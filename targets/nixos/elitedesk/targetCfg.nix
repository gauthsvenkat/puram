rec {
  hostname = "elitedesk";
  system = "x86_64-linux";
  username = "ando";
  homeDirectory = "/home/${username}";
  gitEmail = "gauthsvenkat@gmail.com";
  sshHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgbm/atBI4qLsSPhlb8pnA4BpMe2WetWXkomjNwoWIL root@elitedesk";

  zpool = "dontdie";
  offsiteBucket = "backups";
  paths = rec {
    backups = "/${zpool}/services/backups";
    config = "/var/lib";
    data = "/${zpool}/data";
    postgres = "${config}/postgresql";
  };
  staticLease = {
    ip = "192.168.20.3";
    mac = "00:00:5e:00:53:01";
  };
  tailnetIp = "100.96.0.2";

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
  };
}
