{
  boot = {
    supportedFilesystems = [ "zfs" ];
    # NOTE: The default stays true as long as `stateVersion` is older than 26.11.
    zfs.forceImportRoot = false;
  };

  # ZFS requires `networking.hostId` to be set
  networking.hostId = "0c0ffee0";

  services.zfs.autoScrub.enable = true;
}
