{
  targetCfg,
  ...
}:
let
  inherit (targetCfg) paths;
in
{
  services.immich = {
    enable = true;
    host = "127.0.0.1";
    inherit (targetCfg.ports.immich) port;
    mediaLocation = "${paths.data}/immich";
  };
}
