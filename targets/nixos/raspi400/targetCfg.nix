rec {
  hostname = "raspi400";
  system = "aarch64-linux";
  username = "ando";
  homeDirectory = "/home/${username}";
  gitEmail = "gauthsvenkat@gmail.com";
  sshHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPYeixPiKnt11b9njX3kWUZGbFI9hdJwPoMo6Zadnvuc root@raspi400";
  addresses = {
    lan = "192.168.20.4";
    tailnet = "100.96.0.3";
  };
  mac = "00:00:5e:00:53:01";
}
