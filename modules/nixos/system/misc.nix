{ flakeCfg, nixosCfg, ... }:
let
  inherit (flakeCfg) timezone;
in
{
  system = { inherit (nixosCfg) stateVersion; };

  # Nix-built OpenSSL reads `/etc/ssl/certs/ca-certificates.crt` by default;
  # non-nix programs only find it through `SSL_CERT_FILE`.
  environment.variables.SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";

  programs.nix-ld.enable = true;

  services.fwupd.enable = true;

  time.timeZone = timezone;

  zramSwap.enable = true;
}
