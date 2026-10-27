{ openwrtCfg, targetCfg, ... }:
{
  users.root.hashedPasswordSecret = "hashedPassword";

  uci.settings.system = {
    system = [
      {
        inherit (targetCfg) hostname;
        inherit (openwrtCfg) timezone zonename;
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
