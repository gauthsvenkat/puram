rec {
  hostname = "sentinel";
  system = "aarch64-linux";
  username = "ando";
  homeDirectory = "/home/${username}";
  gitEmail = "gauthsvenkat@gmail.com";
  sshHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAelV4+hlzAdf4KgHcz2umkmgx4SyYnhkQnZsS/PEG7O root@sentinel";
  addresses = {
    headnet = "100.96.0.3";
    vcn = "10.0.0.10";
  };
  headnetPrefixes = {
    v4 = "100.64.0.0/10";
    v6 = "fd7a:115c:a1e0::/48";
  };

  ports = {
    adguard = 3000;
    headscale = 8080;
    headscale-stun = 3478;
    headplane = 3001;
  };
}
