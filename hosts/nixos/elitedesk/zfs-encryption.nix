{
  lib,
  pkgs,
  ...
}:
{
  sops.secrets.zfs_dontdie_key = {
    mode = "0400";
    owner = "root";
  };

  systemd.services.zfs-mount = {
    after = [ "sops-install-secrets.service" ];
    # Override upstream to add `-l`, which loads keys for encrypted filesystems.
    # Leading "" clears the inherited ExecStart; otherwise systemd appends.
    serviceConfig.ExecStart = [
      ""
      "${lib.getExe' pkgs.zfs "zfs"} mount -a -l"
    ];
  };
}
