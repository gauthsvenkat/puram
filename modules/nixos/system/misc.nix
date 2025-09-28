{ pkgs, ... }:
{
  # to run dynamically linked executables
  programs.nix-ld.enable = true;

  #NOTE: By default only NIX_SSL_CERT_FILE is set. Better to set
  # the following to make non-nix programs work as well.
  environment.variables.SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

  time.timeZone = "Europe/Amsterdam";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11";
}
