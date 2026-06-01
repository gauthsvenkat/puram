rec {
  hostname = "toshiba";
  username = "ando";
  isLaptop = false;
  homeDirectory = "/home/${username}";
  gitEmail = "gauthsvenkat@gmail.com";
  wallpaper = "${homeDirectory}/Pictures/wallpapers/astronaut.jpg";

  zpool = "tank";
  domain = "toshiba.example.com";
  paths = rec {
    config = "/${zpool}/services/config";
    databases = "/${zpool}/services/databases";
    postgres = "${databases}/postgres";
    data = "/${zpool}/data";
  };
  ports = {
    adguard = {
      dns_port = 53;
      web_port = 3000;
    };
    immich.port = 2283;
  };
}
