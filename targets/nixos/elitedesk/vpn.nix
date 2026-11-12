{
  inputs,

  targetCfg,

  config,
  lib,
  ...
}:
let
  inherit (targetCfg) ports;
  inherit (targetCfg.vpn) namespace;
  inherit (config.sops) placeholder templates;
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

  sops = {
    secrets = {
      "mullvad_wg_address" = { };
      "mullvad_wg_private_key" = { };
    };

    # Mullvad device: Bright Pug
    templates."mullvad_wg_config".content = ''
      [Interface]
      PrivateKey = ${placeholder."mullvad_wg_private_key"}
      Address = ${placeholder."mullvad_wg_address"}
      DNS = 10.64.0.1

      [Peer]
      PublicKey = ywfkKYdoVAnjsSYW145ACtrw3DV8xTzFS1hlIO7QRD4=
      AllowedIPs = 0.0.0.0/0,::0/0
      Endpoint = 185.209.199.12:51820
    '';
  };

  vpnNamespaces.${namespace} = {
    enable = true;
    wireguardConfigFile = templates."mullvad_wg_config".path;
    inherit (targetCfg.vpn) bridgeAddress namespaceAddress;
    # `portMappings` is used to open ports in the namespace's INPUT firewall.
    # map :: (serviceName::String -> mapping) -> [ serviceName::String ] -> [ mapping ]
    #   where mapping = { from, to :: Int; protocol :: String }
    portMappings = map (name: {
      from = ports.${name}.port;
      to = ports.${name}.port;
      protocol = "tcp";
    }) confined;
  };

  # Bridge to the VPN namespace is an internal control plane -- confined
  # services reach back to host services (sonarr/radarr) via this interface.
  networking.firewall.trustedInterfaces = [ "${namespace}-br" ];

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
