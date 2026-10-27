{ allTargetCfgs, lib, ... }:
let
  elitedesk = allTargetCfgs."elitedesk".staticLease;
in
{
  uci.settings.dhcp = {
    dnsmasq = [
      {
        authoritative = true;
        cachesize = 1000;
        # dnsmasq answers `.lan` itself and forwards the rest to AdGuard Home on elitedesk.
        domain = "lan";
        domainneeded = true;
        expandhosts = true;
        local = "/lan/";
        localise_queries = true;
        localservice = true;
        noresolv = true;
        readethers = true;
        rebind_localhost = true;
        # The public resolvers only answer if elitedesk is down.
        server = [
          elitedesk.ip
          "9.9.9.9"
          "1.1.1.1"
        ];
        strictorder = true;
      }
    ];

    # filterAttrs :: (hostname::String -> targetCfg -> Bool) -> { hostname::String -> targetCfg } -> { hostname::String -> targetCfg }
    # mapAttrsToList :: (hostname::String -> targetCfg -> host) -> { hostname::String -> targetCfg } -> [ host ]
    #   where host = { name, ip, mac :: String }
    # :: [ host ], one per target with a staticLease
    host = lib.mapAttrsToList (name: targetCfg: {
      inherit name;
      inherit (targetCfg.staticLease) ip mac;
    }) (lib.filterAttrs (_: targetCfg: targetCfg ? staticLease) allTargetCfgs);
  };
}
