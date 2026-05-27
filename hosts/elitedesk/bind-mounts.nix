{
  hostCfg,
  ...
}:
let
  inherit (hostCfg) paths;
in
{
  fileSystems =
    let
      bind = device: {
        inherit device;
        fsType = "none";
        options = [
          "bind"
          "x-systemd.after=zfs-mount.service"
          "x-systemd.requires=zfs-mount.service"
        ];
      };
    in
    {
      "/var/lib/private/AdGuardHome" = bind "${paths.config}/adguard-home";
    };
}
