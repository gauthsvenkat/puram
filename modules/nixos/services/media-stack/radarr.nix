{ hostCfg, ... }:
let
  inherit (hostCfg) commonEnvVars images paths;
in
{
  virtualisation.oci-containers.containers.radarr = {
    image = images.radarr;
    environment = { inherit (commonEnvVars) PUID PGID TZ; };
    volumes = [
      "${paths.config}/radarr:/config"
      "${paths.data}/entertainment:/data"
    ];
    dependsOn = [ "gluetun" ];
    extraOptions = [ "--network=container:gluetun" ];
  };
}
