{ config, hostCfg, ... }:
let
  port = hostCfg.ports.homarr.port;
in
{
  sops.secrets.homarr_secret_encryption_key = { };

  virtualisation.oci-containers.containers.homarr = {
    image = hostCfg.images.homarr;
    ports = [ "${toString port}:7575" ];
    environment = {
      inherit (hostCfg.commonEnvVars) TZ;
    };
    environmentFiles = [ config.sops.secrets.homarr_secret_encryption_key.path ];
    volumes = [
      # Homarr's docker integration only knows /var/run/docker.sock. Podman
      # exposes a Docker-compatible API on its own socket, so the path alias
      # lets Homarr talk to podman without any homarr-side changes.
      "/run/podman/podman.sock:/var/run/docker.sock"
      "${hostCfg.paths.config}/homarr/appdata:/appdata"
    ];
  };

  networking.firewall.allowedTCPPorts = [ port ];
}
