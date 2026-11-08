{
  flakeCfg,

  targetCfgs,

  lib,
  ...
}:
let
  inherit (flakeCfg) domain homeserver lanDomain;
  homeserverIp = targetCfgs.nixos.${homeserver}.staticLease.ip;
in
{
  uci.settings.dhcp = {
    dnsmasq = [
      {
        authoritative = true;
        cachesize = 1000;
        # dnsmasq answers `lanDomain` itself and forwards the rest to AdGuard Home.
        domain = lanDomain;
        domainneeded = true;
        expandhosts = true;
        local = "/${lanDomain}/";
        localise_queries = true;
        localservice = false;
        noresolv = true;
        readethers = true;
        rebind_domain = [ domain ];
        rebind_localhost = true;
        # The public resolvers only answer if AdGuard Home is down.
        server = [
          homeserverIp
          "9.9.9.9"
          "1.1.1.1"
        ];
        strictorder = true;
      }
    ];

    # filterAttrs :: (hostname::String -> targetCfg -> Bool) -> { hostname::String -> targetCfg } -> { hostname::String -> targetCfg }
    # mapAttrsToList :: (hostname::String -> targetCfg -> host) -> { hostname::String -> targetCfg } -> [ host ]
    #   where host = { name, ip, mac :: String; dns :: Bool }
    # :: [ host ], one per target with a staticLease
    host = lib.mapAttrsToList (name: targetCfg: {
      inherit name;
      inherit (targetCfg.staticLease) ip mac;
      dns = true;
    }) (lib.filterAttrs (_: targetCfg: targetCfg ? staticLease) targetCfgs.nixos);
  };
}
