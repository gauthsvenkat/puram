rec {
  hostname = "sentinel";
  system = "aarch64-linux";
  username = "ando";
  homeDirectory = "/home/${username}";
  gitEmail = "gauthsvenkat@gmail.com";
  sshHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAelV4+hlzAdf4KgHcz2umkmgx4SyYnhkQnZsS/PEG7O root@sentinel";
  vcnIp = "10.0.0.10";

  ports.adguard.port = 3000;
}
