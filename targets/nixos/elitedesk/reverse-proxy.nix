{
  flakeCfg,
  targetCfg,

  config,
  ...
}:
let
  inherit (flakeCfg) domains;
  inherit (targetCfg) ports;
  # BEGIN-PRIVATE
  inherit (targetCfg) vpn;
  # END-PRIVATE
  cfg_caddy = config.services.caddy;
  cfg_phpfpm = config.services.phpfpm;
  cfg_st = config.services.speedtest-tracker;

  # BEGIN-PRIVATE
  # VPN-confined services bind on the namespace's internal IP rather
  # than host loopback. Caddy reaches them via the bridge.
  proxyVpn = p: ''
    reverse_proxy ${vpn.namespaceAddress}:${toString p}
  '';
  # END-PRIVATE
in
{
  imports = [
    ../../../modules/nixos/services/caddy.nix
  ];

  # Caddy serves speedtest-tracker via `php_fastcgi`; the phpfpm pool socket is
  # mode `0660` owned by the speedtest user/group, so caddy needs the group.
  users.users.${cfg_caddy.user}.extraGroups = [ cfg_st.group ];

  services.caddy.virtualHosts =
    let
      proxy = p: ''
        reverse_proxy 127.0.0.1:${toString p}
      '';
    in
    {
      "homepage.${domains.apex}".extraConfig = proxy ports.homepage;
      "immich.${domains.apex}".extraConfig = proxy ports.immich;
      "jellyfin.${domains.apex}".extraConfig = proxy ports.jellyfin;
      "paperless.${domains.apex}".extraConfig = proxy ports.paperless;
      # Speedtest-tracker is a Laravel app; Caddy serves static assets directly
      # and hands PHP off to a phpfpm pool. The doc-root and socket come from
      # the speedtest-tracker NixOS module's evaluated config.
      "speedtest.${domains.apex}".extraConfig = ''
        root * ${cfg_st.package}/public
        encode zstd gzip
        @static path *.js *.css *.gif *.png *.ico *.jpg *.jpeg
        header @static Cache-Control "public, max-age=31536000, immutable"
        php_fastcgi unix/${cfg_phpfpm.pools.speedtest-tracker.socket}
        file_server
      '';
      "vikunja.${domains.apex}".extraConfig = proxy ports.vikunja;
      # BEGIN-PRIVATE
      "bazarr.${domains.apex}".extraConfig = proxy ports.bazarr;
      "bitmagnet.${domains.apex}".extraConfig = proxyVpn ports.bitmagnet;
      "prowlarr.${domains.apex}".extraConfig = proxyVpn ports.prowlarr;
      "qbittorrent.${domains.apex}".extraConfig = proxyVpn ports.qbittorrent;
      "radarr.${domains.apex}".extraConfig = proxy ports.radarr;
      "sabnzbd.${domains.apex}".extraConfig = proxyVpn ports.sabnzbd;
      "seerr.${domains.apex}".extraConfig = proxy ports.seerr;
      "sonarr.${domains.apex}".extraConfig = proxy ports.sonarr;
      # END-PRIVATE
    };
}
