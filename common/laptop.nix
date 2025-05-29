{
  services = {
    # Disable power-profiles-daemon in favor of TLP
    power-profiles-daemon.enable = false;
    tlp.enable = true;
  };
}
