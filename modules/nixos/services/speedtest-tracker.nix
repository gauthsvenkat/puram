{ config, hostCfg, ... }:
let
  inherit (hostCfg) domain paths;
  cfg_st = config.services.speedtest-tracker;
  cfg_caddy = config.services.caddy;
  cfg_phpfpm = config.services.phpfpm;
  inherit (config.sops) secrets;
  vhost = "speedtest.${domain}";
in
{
  sops.secrets.speedtest_tracker_app_key = {
    owner = cfg_st.user;
    inherit (cfg_st) group;
  };

  services.speedtest-tracker = {
    enable = true;
    virtualHost = vhost;
    dataDir = "${paths.config}/speedtest-tracker";
    settings = {
      APP_KEY_FILE = secrets.speedtest_tracker_app_key.path;
      SPEEDTEST_SCHEDULE = "18 * * * *";
    };
  };

  # The phpfpm pool socket is owned by the speedtest-tracker service
  # user/group (mode 0660); add caddy to the group so Caddy's php_fastcgi
  # can read it.
  users.users.${cfg_caddy.user}.extraGroups = [ cfg_st.group ];

  services.caddy.virtualHosts.${vhost}.extraConfig = ''
    root * ${cfg_st.package}/public
    encode zstd gzip
    @static path *.js *.css *.gif *.png *.ico *.jpg *.jpeg
    header @static Cache-Control "public, max-age=31536000, immutable"
    php_fastcgi unix/${cfg_phpfpm.pools.speedtest-tracker.socket}
    file_server
  '';
}
