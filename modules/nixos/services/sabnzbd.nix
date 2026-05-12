{ hostCfg, ... }:
let
  inherit (hostCfg) domain;
  inherit (hostCfg.paths) usenet;
  inherit (hostCfg.ports.sabnzbd) port;
  inherit (hostCfg.vpn) namespaceAddress;
in
{
  services.sabnzbd = {
    enable = true;
    # Allows mutating config file through UI.
    allowConfigWrite = true;
    settings.misc = {
      host = namespaceAddress;
      inherit port;
      # Caddy proxies as `sabnzbd.<domain>`; direct sonarr/radarr hits land
      # as `<namespaceAddress>:<port>`. Both must be in the whitelist.
      host_whitelist = "sabnzbd.${domain},${namespaceAddress}";
      download_dir = "${usenet}/incomplete";
      complete_dir = "${usenet}/complete";
      # chmod completed downloads to 775 so sonarr/radarr (media group)
      # can traverse and import. sabnzbd creates working dirs as 0700;
      # without this they'd stay 0700 on move-to-complete.
      permissions = "775";
    };
  };
}
