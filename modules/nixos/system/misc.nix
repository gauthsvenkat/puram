{ pkgs, ... }:
{
  programs.nix-ld.enable = true;

  # NixOS sets `NIX_SSL_CERT_FILE` by default; `SSL_CERT_FILE` is what non-nix
  # programs look for.
  environment.variables.SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

  services.fwupd.enable = true;

  time.timeZone = "Europe/Amsterdam";

  system.stateVersion = "26.05";
}
