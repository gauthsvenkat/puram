{ targetCfg, ... }:
{
  users.root.hashedPasswordSecret = "hashedPassword"; # refers to the secret in sops.

  uci.settings.system = {
    system = [
      {
        inherit (targetCfg) hostname;
        timezone = "CET-1CEST,M3.5.0,M10.5.0/3";
        zonename = "Europe/Amsterdam";
      }
    ];

    timeserver.ntp = {
      enabled = true;
      server = [
        "0.openwrt.pool.ntp.org"
        "1.openwrt.pool.ntp.org"
        "2.openwrt.pool.ntp.org"
        "3.openwrt.pool.ntp.org"
      ];
    };
  };
}
