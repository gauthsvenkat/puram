{
  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs = {
      # By default, following option is true for legacy reasons.
      forceImportRoot = false;
    };
  };

  # ZFS requires networking.hostId to be set
  networking.hostId = "0c0ffee0";

  services.zfs.autoScrub.enable = true;
}
