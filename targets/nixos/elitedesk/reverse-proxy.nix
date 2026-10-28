{
  flakeCfg,
  targetCfg,

  config,
  ...
}:
let
  inherit (flakeCfg) domain;
  inherit (targetCfg.ports)
    homepage
    immich
    jellyfin
    paperless
    vikunja
    ;
  cfg_st = config.services.speedtest-tracker;
  cfg_caddy = config.services.caddy;
  cfg_phpfpm = config.services.phpfpm;

  proxy = p: ''
    reverse_proxy 127.0.0.1:${toString p}
  '';
in
{
  imports = [
    ../../../modules/nixos/services/caddy.nix
  ];

  # Caddy serves speedtest-tracker via `php_fastcgi`; the phpfpm pool socket is
  # mode `0660` owned by the speedtest user/group, so caddy needs the group.
  users.users.${cfg_caddy.user}.extraGroups = [ cfg_st.group ];

  services.caddy.virtualHosts = {
    "homepage.${domain}".extraConfig = proxy homepage.port;
    "jellyfin.${domain}".extraConfig = proxy jellyfin.port;
    "immich.${domain}".extraConfig = proxy immich.port;
    "paperless.${domain}".extraConfig = proxy paperless.port;
    "vikunja.${domain}".extraConfig = proxy vikunja.port;
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
