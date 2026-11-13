{
  targetCfg,
  ...
}:
let
  inherit (targetCfg) paths ports;
in
{
  services.immich = {
    enable = true;
    host = "127.0.0.1";
    mediaLocation = "${paths.data}/immich";
    port = ports.immich;
  };
}
