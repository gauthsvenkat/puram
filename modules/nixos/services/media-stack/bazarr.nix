{ hostCfg, ... }:
let
  inherit (hostCfg) commonEnvVars images paths;
in
{
  virtualisation.oci-containers.containers.bazarr = {
    image = images.bazarr;
    environment = { inherit (commonEnvVars) PUID PGID TZ; };
    volumes = [
      "${paths.config}/bazarr:/config"
      "${paths.data}/entertainment:/data"
    ];
    dependsOn = [ "gluetun" ];
    extraOptions = [ "--network=container:gluetun" ];
  };
}
