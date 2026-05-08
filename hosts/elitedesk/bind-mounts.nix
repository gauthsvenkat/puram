{
  hostCfg,
  ...
}:
let
  inherit (hostCfg) paths zpool;
in
{
  # Bind-mount native services' state onto the ZFS pool so app data is
  # snapshot-managed alongside everything else.
  #
  # AdGuard Home and Stirling PDF run with `DynamicUser=true`. Per
  # systemd.exec(5), DynamicUser redirects `StateDirectory=` to
  # `/var/lib/private/<name>` (a root-only parent that guards against UID
  # recycling), and leaves `/var/lib/<name>` as a symlink for transparency.
  # We bind the private path so DynamicUser keeps working unchanged. If
  # systemd ever changes this internal layout, these mounts need revisiting.
  # Ref: https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#StateDirectory=
  fileSystems = {
    "/var/lib/private/AdGuardHome" = {
      device = "${paths.config}/adguard-home";
      fsType = "none";
      options = [ "bind" ];
      depends = [ "/${zpool}" ];
    };
    "/var/lib/private/stirling-pdf" = {
      device = "${paths.config}/stirling-pdf";
      fsType = "none";
      options = [ "bind" ];
      depends = [ "/${zpool}" ];
    };
  };
}
