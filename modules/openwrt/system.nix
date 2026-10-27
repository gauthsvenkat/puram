{ openwrtCfg, targetCfg, ... }:
{
  users.root.hashedPasswordSecret = "hashedPassword";

  uci.settings.system = {
    system = [
      {
        inherit (openwrtCfg) timezone zonename;
        inherit (targetCfg) hostname;
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
