{
  boot = {
    supportedFilesystems = [ "zfs" ];
    # NOTE: Keep while `stateVersion` is older than 26.11; the default is `true` until then.
    zfs.forceImportRoot = false;
  };

  # ZFS requires `networking.hostId` to be set
  networking.hostId = "0c0ffee0";

  services.zfs.autoScrub.enable = true;
}
