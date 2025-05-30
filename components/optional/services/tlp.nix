{
  services = {
    # NOTE: powerppower-profiles-daemon needs to be explicitly disabled
    # to enable tlp
    power-profiles-daemon.enable = false;
    tlp.enable = true;
  };
}
