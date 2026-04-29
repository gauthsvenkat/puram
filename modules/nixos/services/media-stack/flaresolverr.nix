{ hostCfg, ... }:
let
  inherit (hostCfg) commonEnvVars images;
in
{
  virtualisation.oci-containers.containers.flaresolverr = {
    image = images.flaresolverr;
    environment = {
      inherit (commonEnvVars) TZ;
      LOG_LEVEL = "info";
    };
    dependsOn = [ "gluetun" ];
    extraOptions = [ "--network=container:gluetun" ];
  };
}
