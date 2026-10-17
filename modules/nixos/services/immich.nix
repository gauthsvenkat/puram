{
  targetCfg,
  ...
}:
let
  inherit (targetCfg) paths;
  inherit (targetCfg.ports.immich) port;
in
{
  services.immich = {
    enable = true;
    host = "127.0.0.1";
    inherit port;
    mediaLocation = "${paths.data}/immich";
  };
}
