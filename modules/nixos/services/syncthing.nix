{ hostCfg, ... }:
let
  inherit (hostCfg) username homeDirectory;
in
{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = username;
    dataDir = homeDirectory;

    # LAN-only sync: skip global discovery, relays, and UOnP NAT punching.
    # https://docs.syncthing.net/users/config.html#config-option-options.globalannounceenabled
    settings.options = {
      globalAnnounceEnabled = false;
      relaysEnabled = false;
      natEnabled = false;
    };
  };
}
