{
  flakeCfg,

  targetCfgs,

  lib,
  ...
}:
let
  inherit (flakeCfg) domain homeserver lanDomain;
  homeserverIp = targetCfgs.nixos.${homeserver}.staticLease.ip;
  # filterAttrs :: (hostname::String -> targetCfg -> Bool) -> { hostname::String -> targetCfg } -> { hostname::String -> targetCfg }
  # :: { hostname::String -> targetCfg }, hosts with a staticLease
  staticLeaseCfgs = lib.filterAttrs (_: targetCfg: targetCfg ? staticLease) targetCfgs.nixos;
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
        # `strictorder`: sentinel's AdGuard Home over DoH through `127.0.0.1#5053`, then the
        # homeserver's; the public resolvers only answer if both are down.
        server = [
          "127.0.0.1#5053"
          homeserverIp
          "9.9.9.9"
          "1.1.1.1"
        ];
        strictorder = true;
      }
    ];

    # mapAttrsToList :: (hostname::String -> targetCfg -> host) -> { hostname::String -> targetCfg } -> [ host ]
    #   where host = { name, ip, mac :: String; dns :: Bool }
    host = lib.mapAttrsToList (name: targetCfg: {
      inherit name;
      inherit (targetCfg.staticLease) ip mac;
      dns = true;
    }) staticLeaseCfgs;
  };
}
