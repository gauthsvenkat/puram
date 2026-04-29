{ config, hostCfg, ... }:
let
  cfg = config.services.speedtest-tracker;
in
{
  sops.secrets.speedtest_tracker_app_key = {
    owner = cfg.user;
    group = cfg.group;
  };

  services.speedtest-tracker = {
    enable = true;
    enableNginx = true;
    dataDir = "${hostCfg.paths.config}/speedtest-tracker";
    settings = {
      APP_KEY_FILE = config.sops.secrets.speedtest_tracker_app_key.path;
      SPEEDTEST_SCHEDULE = "18 * * * *";
    };
  };

  # nginx (via enableNginx above) listens on :80; the NixOS firewall is on by
  # default (networking.firewall.enable defaults to true) and neither this
  # module nor services.nginx exposes openFirewall, so we open it manually.
  networking.firewall.allowedTCPPorts = [ hostCfg.ports.speedtestTracker.port ];
}
