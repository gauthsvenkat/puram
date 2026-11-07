{
  boot.supportedFilesystems = [ "zfs" ];

  # ZFS requires `networking.hostId` to be set
  networking.hostId = "0c0ffee0";

  services.zfs.autoScrub.enable = true;
}
