rec {
  hostname = "thinkpad-t14s";
  system = "x86_64-linux";
  username = "gautham";
  homeDirectory = "/home/${username}";
  gitEmail = "user@work.example";
  sshUserKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFj/yG1nbUNFgy8cFuTFexgCD4EsypDoetQ/bx6bg/HY gautham@thinkpad-t14s";
  wallpaper = "${homeDirectory}/Pictures/wallpapers/astronaut.jpg";
}
