{
  hostCfg,
  ...
}:
let
  inherit (hostCfg) paths;
  inherit (hostCfg.ports.immich) port;
in
{
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    inherit port;
    mediaLocation = "${paths.data}/immich";
  };
}
