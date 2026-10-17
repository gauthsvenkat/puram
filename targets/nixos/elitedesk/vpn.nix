{
  config,
  targetCfg,
  inputs,
  lib,
  ...
}:
let
  inherit (targetCfg.vpn) namespace;
  inherit (config.sops) placeholder;
  confined = [
    "bitmagnet"
    "flaresolverr"
    "prowlarr"
    "qbittorrent"
    "sabnzbd"
  ];
in
{
  imports = [ inputs.vpn-confinement.nixosModules.default ];

  # Bridge to the VPN namespace is an internal control plane -- confined
  # services reach back to host services (sonarr/radarr) via this interface.
  networking.firewall.trustedInterfaces = [ "${namespace}-br" ];

  sops.secrets = {
    mullvad_wg_address = { };
    mullvad_wg_private_key = { };
  };

  # Device: Bright Pug
  sops.templates.mullvad_wg_config.content = ''
    [Interface]
    PrivateKey = ${placeholder.mullvad_wg_private_key}
    Address = ${placeholder.mullvad_wg_address}
    DNS = 10.64.0.1

    [Peer]
    PublicKey = Vh3Y2LsBG1yN4kDeebOr3J6dFooGJIBTftzVqlWhiD4=
    AllowedIPs = 0.0.0.0/0,::0/0
    Endpoint = 185.209.199.17:51820
  '';

  vpnNamespaces.${namespace} = {
    enable = true;
    wireguardConfigFile = config.sops.templates.mullvad_wg_config.path;
    inherit (targetCfg.vpn) bridgeAddress namespaceAddress;
    # portMappings is used to open ports in the namespace's INPUT firewall.
    # map :: (serviceName::String -> mapping) -> [ serviceName::String ] -> [ mapping ]
    #   where mapping = { from, to :: Int; protocol :: String }
    portMappings = map (name: {
      from = targetCfg.ports.${name}.port;
      to = targetCfg.ports.${name}.port;
      protocol = "tcp";
    }) confined;
  };

  # listToAttrs :: [ { name :: String; value :: service } ] -> { serviceName::String -> service }
  #   where service = { vpnConfinement :: { enable :: Bool; vpnNamespace :: String } }
  systemd.services = lib.listToAttrs (
    map (s: {
      name = s;
      value.vpnConfinement = {
        enable = true;
        vpnNamespace = namespace;
      };
    }) confined
  );
}
