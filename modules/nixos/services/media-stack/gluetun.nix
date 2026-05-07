# Mullvad WireGuard VPN gateway. Every other container in this folder shares
# this container's network namespace, so all dependents' egress flows through
# Mullvad and their listeners are exposed only via the port mappings declared
# here. Flaresolverr (8191) is intentionally not mapped — *arr reach it at
# localhost:8191 inside the shared netns; no external consumer needs it.
#
# No host firewall opens needed: docker (and podman with default networking)
# DNATs published ports in PREROUTING and forwards them through its own chain,
# bypassing NixOS firewall's INPUT filter.
{ config, hostCfg, ... }:
let
  inherit (hostCfg) commonEnvVars images ports;
  inherit (config.sops) secrets;
in
{
  sops.secrets.gluetun_wireguard_env = { };

  virtualisation.oci-containers.containers.gluetun = {
    image = images.gluetun;
    environment = {
      VPN_SERVICE_PROVIDER = "mullvad";
      VPN_TYPE = "wireguard";
      SERVER_COUNTRIES = "Switzerland,Sweden,Spain";
      OWNED_ONLY = "yes";
      inherit (commonEnvVars) TZ;
    };
    environmentFiles = [ secrets.gluetun_wireguard_env.path ];
    ports = [
      "${toString ports.bazarr.port}:6767"
      "${toString ports.prowlarr.port}:9696"
      "${toString ports.qbittorrent.port}:8082"
      "${toString ports.radarr.port}:7878"
      "${toString ports.sabnzbd.port}:8080"
      "${toString ports.sonarr.port}:8989"
      "${toString ports.qbittorrent.bt_port}:6881/tcp"
      "${toString ports.qbittorrent.bt_port}:6881/udp"
    ];
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--device=/dev/net/tun:/dev/net/tun"
    ];
  };
}
