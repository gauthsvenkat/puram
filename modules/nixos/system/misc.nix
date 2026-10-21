{
  programs.nix-ld.enable = true;

  # Nix-built OpenSSL reads `/etc/ssl/certs/ca-certificates.crt` by default;
  # non-nix programs only find it through `SSL_CERT_FILE`.
  environment.variables.SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";

  services.fwupd.enable = true;

  time.timeZone = "Europe/Amsterdam";

  system.stateVersion = "26.05";
}
