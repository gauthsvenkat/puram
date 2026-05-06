{ config, hostCfg, ... }:
let
  cfg = config.services.speedtest-tracker;
  vhost = "speedtest.${hostCfg.domain}";
in
{
  sops.secrets.speedtest_tracker_app_key = {
    owner = cfg.user;
    group = cfg.group;
  };

  services.speedtest-tracker = {
    enable = true;
    virtualHost = vhost;
    dataDir = "${hostCfg.paths.config}/speedtest-tracker";
    settings = {
      APP_KEY_FILE = config.sops.secrets.speedtest_tracker_app_key.path;
      SPEEDTEST_SCHEDULE = "18 * * * *";
    };
  };

  # The phpfpm pool socket is owned by the speedtest-tracker service
  # user/group (mode 0660); add caddy to the group so Caddy's php_fastcgi
  # can read it.
  users.users.${config.services.caddy.user}.extraGroups = [ cfg.group ];

  services.caddy.virtualHosts.${vhost}.extraConfig = ''
    root * ${cfg.package}/public
    encode zstd gzip
    @static path *.js *.css *.gif *.png *.ico *.jpg *.jpeg
    header @static Cache-Control "public, max-age=31536000, immutable"
    php_fastcgi unix/${config.services.phpfpm.pools.speedtest-tracker.socket}
    file_server
  '';
}
