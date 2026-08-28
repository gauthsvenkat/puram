rec {
  hostname = "thunderdome";
  username = "ando";
  homeDirectory = "/home/${username}";
  gitEmail = "gauthsvenkat@gmail.com";
  sshUserKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINyRTUCgazY6gGUf76EMhgroZ1fFPFMHcX0UkpkPJkDk ando@thunderdome";
  wallpaper = "${homeDirectory}/Pictures/wallpapers/astronaut.jpg";

  zpool = "dontdie";
}
