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
    mediaLocation = "${paths.data}/immich";
    inherit (targetCfg.ports.immich) port;
  };
}
