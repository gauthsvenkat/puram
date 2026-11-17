{
  services.smartd = {
    enable = true;
    # Exit cleanly on hosts without SMART devices, e.g. VMs.
    extraOptions = [ "--quit=nodev0" ];
  };
}
