{ targetCfg, ... }:
let
  inherit (targetCfg) username homeDirectory;
in
{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = username;
    dataDir = homeDirectory;

    # LAN-only sync: skip global discovery, relays, and UPnP NAT punching.
    # https://docs.syncthing.net/users/config.html#config-option-options.globalannounceenabled
    settings.options = {
      globalAnnounceEnabled = false;
      relaysEnabled = false;
      natEnabled = false;
    };
  };
}
