rec {
  hostname = "raspi400";
  system = "aarch64-linux";
  username = "ando";
  homeDirectory = "/home/${username}";
  gitEmail = "gauthsvenkat@gmail.com";
  sshHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPYeixPiKnt11b9njX3kWUZGbFI9hdJwPoMo6Zadnvuc root@raspi400";
  addresses = {
    lan = "192.168.20.4";
    headnet = "100.64.0.1";
  };
  mac = "e4:5f:01:06:ae:59";
}
