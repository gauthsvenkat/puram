{
  services = {
    # NOTE: Fingerprint disabled since it is very annoying
    fprintd.enable = false;

    # Disable power-profiles-daemon in favor of TLP
    power-profiles-daemon.enable = false;
    tlp.enable = true;
  };
}
