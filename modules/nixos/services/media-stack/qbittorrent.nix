{ hostCfg, ... }:
let
  inherit (hostCfg)
    commonEnvVars
    domain
    images
    paths
    ports
    ;
in
{
  virtualisation.oci-containers.containers.qbittorrent = {
    image = images.qbittorrent;
    environment = {
      inherit (commonEnvVars) PUID PGID TZ;
      # WEBUI_PORT is set explicitly because qbittorrent binds to a non-default
      # webui port to avoid colliding with sabnzbd's 8080 inside gluetun's netns.
      WEBUI_PORT = toString ports.qbittorrent.port;
    };
    volumes = [
      "${paths.config}/qbittorrent:/config"
      "${paths.data}/entertainment/torrents:/data/torrents"
    ];
    dependsOn = [ "gluetun" ];
    extraOptions = [ "--network=container:gluetun" ];
  };

  services.caddy.virtualHosts."qbittorrent.${domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString ports.qbittorrent.port}
  '';
}
