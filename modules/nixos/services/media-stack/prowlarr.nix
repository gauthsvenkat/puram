{ hostCfg, ... }:
let
  inherit (hostCfg)
    commonEnvVars
    images
    paths
    ;
in
{
  virtualisation.oci-containers.containers.prowlarr = {
    image = images.prowlarr;
    environment = { inherit (commonEnvVars) PUID PGID TZ; };
    volumes = [ "${paths.config}/prowlarr:/config" ];
    dependsOn = [ "gluetun" ];
    extraOptions = [ "--network=container:gluetun" ];
  };
}
