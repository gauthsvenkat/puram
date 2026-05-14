{
  hostCfg,
  config,
  ...
}:
let
  inherit (hostCfg) domain;
  inherit (hostCfg.ports)
    adguard
    # BEGIN-PRIVATE
    bazarr
    # END-PRIVATE
    homepage
    immich
    jellyfin
    paperless
    # BEGIN-PRIVATE
    prowlarr
    qbittorrent
    radarr
    sabnzbd
    seerr
    sonarr
    # END-PRIVATE
    ;
  # BEGIN-PRIVATE
  inherit (hostCfg.vpn) namespaceAddress;
  # END-PRIVATE
  cfg_st = config.services.speedtest-tracker;
  cfg_caddy = config.services.caddy;
  cfg_phpfpm = config.services.phpfpm;

  proxy = p: ''
    reverse_proxy 127.0.0.1:${toString p}
  '';
  # BEGIN-PRIVATE
  # VPN-confined services bind on the namespace's internal IP rather
  # than host loopback. Caddy reaches them via the bridge.
  proxyVpn = p: ''
    reverse_proxy ${namespaceAddress}:${toString p}
  '';
  # END-PRIVATE
in
{
  imports = [
    ../../modules/nixos/services/caddy.nix
  ];

  # Caddy serves speedtest-tracker via php_fastcgi; the phpfpm pool socket is
  # mode 0660 owned by the speedtest user/group, so caddy needs the group.
  users.users.${cfg_caddy.user}.extraGroups = [ cfg_st.group ];

  services.caddy.virtualHosts = {
    "homepage.${domain}".extraConfig = proxy homepage.port;
    "jellyfin.${domain}".extraConfig = proxy jellyfin.port;
    "immich.${domain}".extraConfig = proxy immich.port;
    "paperless.${domain}".extraConfig = proxy paperless.port;
    # BEGIN-PRIVATE
    "sonarr.${domain}".extraConfig = proxy sonarr.port;
    "radarr.${domain}".extraConfig = proxy radarr.port;
    "prowlarr.${domain}".extraConfig = proxyVpn prowlarr.port;
    "bazarr.${domain}".extraConfig = proxy bazarr.port;
    "qbittorrent.${domain}".extraConfig = proxyVpn qbittorrent.port;
    "sabnzbd.${domain}".extraConfig = proxyVpn sabnzbd.port;
    "seerr.${domain}".extraConfig = proxy seerr.port;
    # END-PRIVATE
    "adguard.${domain}".extraConfig = proxy adguard.web_port;
    # Speedtest-tracker is a Laravel app; Caddy serves static assets directly
    # and hands PHP off to a phpfpm pool. The doc-root and socket come from
    # the speedtest-tracker NixOS module's evaluated config.
    "speedtest.${domain}".extraConfig = ''
      root * ${cfg_st.package}/public
      encode zstd gzip
      @static path *.js *.css *.gif *.png *.ico *.jpg *.jpeg
      header @static Cache-Control "public, max-age=31536000, immutable"
      php_fastcgi unix/${cfg_phpfpm.pools.speedtest-tracker.socket}
      file_server
    '';
  };
}
