# Mullvad WireGuard VPN gateway. Every other container in this folder shares
# this container's network namespace, so all dependents' egress flows through
# Mullvad and their listeners are exposed only via the port mappings declared
# here.
#
# No host firewall opens needed: docker (and podman with default networking)
# DNATs published ports in PREROUTING and forwards them through its own chain,
# bypassing NixOS firewall's INPUT filter.
{ config, hostCfg, ... }:
let
  inherit (hostCfg) commonEnvVars images;
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
    # Gluetun has no consumers left; Phase 4 deletes this module entirely.
    ports = [ ];
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--device=/dev/net/tun:/dev/net/tun"
    ];
  };
}
