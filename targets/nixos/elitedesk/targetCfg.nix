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
  addresses = {
    headnet = "100.96.0.2";
    lan = "192.168.20.3";
  };
  mac = "00:00:5e:00:53:01";

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
  };
}
