{
  flakeCfg,
  targetCfg,

  config,
  ...
}:
let
  inherit (flakeCfg) domain;
  inherit (targetCfg) paths;
  cfg = config.services.speedtest-tracker;
  inherit (config.sops) secrets;
in
{
  sops.secrets."speedtest_tracker_app_key" = {
    restartUnits = [ "speedtest-tracker.service" ];
    owner = cfg.user;
    inherit (cfg) group;
  };

  services.speedtest-tracker = {
    enable = true;
    virtualHost = "speedtest.${domain}";
    dataDir = "${paths.config}/speedtest-tracker";
    settings = {
      APP_KEY_FILE = secrets."speedtest_tracker_app_key".path;
      SPEEDTEST_SCHEDULE = "18 * * * *";
    };
  };
}
