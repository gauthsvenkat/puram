{
  hostCfg,
  ...
}:
let
  inherit (hostCfg) paths zpool;
in
{
  fileSystems =
    let
      bind = device: {
        inherit device;
        fsType = "none";
        options = [ "bind" ];
        depends = [ "/${zpool}" ];
      };
    in
    {
      "/var/lib/private/AdGuardHome" = bind "${paths.config}/adguard-home";
    };
}
