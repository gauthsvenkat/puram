{
  flakeCfg,
  targetCfg,

  config,
  ...
}:
let
  inherit (flakeCfg) domains;
  inherit (targetCfg) paths;
  inherit (config.sops) secrets;
  cfg = config.services.speedtest-tracker;
in
{
  sops.secrets."speedtest_tracker_app_key" = {
    inherit (cfg) group;
    owner = cfg.user;
    restartUnits = [ "speedtest-tracker.service" ];
  };

  services.speedtest-tracker = {
    enable = true;
    dataDir = "${paths.config}/speedtest-tracker";
    settings = {
      APP_KEY_FILE = secrets."speedtest_tracker_app_key".path;
      SPEEDTEST_SCHEDULE = "18 * * * *";
    };
    virtualHost = "speedtest.${domains.apex}";
  };
}
