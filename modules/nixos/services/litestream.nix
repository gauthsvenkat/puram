{ config, ... }:
let
  inherit (config.sops) templates;
in
{
  sops.templates."litestream_env".restartUnits = [ "litestream.service" ];

  services.litestream = {
    enable = true;
    environmentFile = templates."litestream_env".path;
    settings.snapshot.retention = "168h";
  };
}
