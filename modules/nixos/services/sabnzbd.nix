{ flakeCfg, targetCfg, ... }:
let
  inherit (flakeCfg) domain;
  inherit (targetCfg) paths ports vpn;
in
{
  services.sabnzbd = {
    enable = true;
    allowConfigWrite = true;
    settings.misc = {
      download_dir = "${paths.usenet}/incomplete";
      complete_dir = "${paths.usenet}/complete";
      host = vpn.namespaceAddress;
      # Caddy proxies as `sabnzbd.<domain>`; direct sonarr/radarr hits land
      # as `<namespaceAddress>:<port>`. Both must be in the whitelist.
      host_whitelist = "sabnzbd.${domain},${vpn.namespaceAddress}";
      # chmod completed downloads to `775` so sonarr/radarr (media group)
      # can traverse and import. sabnzbd creates working dirs as `0700`;
      # without this they'd stay `0700` on move-to-complete.
      permissions = "775";
      port = ports.sabnzbd;
    };
  };
}
