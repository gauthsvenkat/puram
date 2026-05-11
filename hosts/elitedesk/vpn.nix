{
  inputs,
  config,
  hostCfg,
  ...
}:
let
  inherit (hostCfg.vpn) namespace bridgeAddress namespaceAddress;
  inherit (config.sops) secrets;
  confined = [
    "prowlarr"
  ];
in
{
  imports = [ inputs.vpn-confinement.nixosModules.default ];

  # Bridge to the VPN namespace is an internal control plane -- confined
  # services reach back to host services (sonarr/radarr) via this interface.
  networking.firewall.trustedInterfaces = [ "${namespace}-br" ];

  sops.secrets.mullvad_wg_config = { };

  vpnNamespaces.${namespace} = {
    enable = true;
    wireguardConfigFile = secrets.mullvad_wg_config.path;
    inherit bridgeAddress namespaceAddress;
    # portMappings is used to open ports in the namespace's INPUT firewall.
    portMappings = map (name: {
      from = hostCfg.ports.${name}.port;
      to = hostCfg.ports.${name}.port;
      protocol = "tcp";
    }) confined;
  };

  systemd.services = builtins.listToAttrs (
    map (s: {
      name = s;
      value.vpnConfinement = {
        enable = true;
        vpnNamespace = namespace;
      };
    }) confined
  );
}
