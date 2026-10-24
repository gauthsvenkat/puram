rec {
  hostname = "elitedesk";
  system = "x86_64-linux";
  username = "ando";
  homeDirectory = "/home/${username}";
  gitEmail = "gauthsvenkat@gmail.com";
  sshHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgbm/atBI4qLsSPhlb8pnA4BpMe2WetWXkomjNwoWIL root@elitedesk";

  zpool = "dontdie";
  domain = "example.com";
  tailnetIp = "100.64.0.1";
  lan = {
    ip = "192.168.1.3";
    mac = "00:00:5e:00:53:01";
  };
  paths = rec {
    config = "/var/lib";
    postgres = "${config}/postgresql";
    backups = "/${zpool}/services/backups";
    data = "/${zpool}/data";
  };

  ports = {
    adguard = {
      dns_port = 53;
      web_port = 3000;
    };
    # Caddy hardcodes its admin API port; this only mirrors it.
    caddy.admin_port = 2019;
    homepage.port = 7575;
    immich.port = 2283;
    # `services.jellyfin` hardcodes this port; this only mirrors it.
    jellyfin.port = 8096;
    paperless = {
      port = 8000;
      gotenberg_port = 3030;
      tika_port = 9998;
    };
    vikunja.port = 3456;
  };
}
