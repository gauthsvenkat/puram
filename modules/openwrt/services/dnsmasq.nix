{
  flakeCfg,
  targetCfg,

  targetCfgs,

  lib,
  ...
}:
let
  inherit (flakeCfg) domain homeserver lanDomain;
  inherit (targetCfg) ports;
  homeserverIp = targetCfgs.nixos.${homeserver}.addresses.lan;
  # filterAttrs :: (hostname::String -> targetCfg -> Bool) -> { hostname::String -> targetCfg } -> { hostname::String -> targetCfg }
  # :: { hostname::String -> targetCfg }, hosts with a LAN address
  lanCfgs = lib.filterAttrs (_: hostCfg: hostCfg ? addresses.lan) targetCfgs.nixos;
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
        # `strictorder`: sentinel's AdGuard Home over DoH through https-dns-proxy, then the
        # homeserver's; the public resolvers only answer if both are down.
        server = [
          "127.0.0.1#${toString ports.doh}"
          homeserverIp
          "9.9.9.9"
          "1.1.1.1"
        ];
        strictorder = true;
      }
    ];

    # mapAttrsToList :: (hostname::String -> targetCfg -> host) -> { hostname::String -> targetCfg } -> [ host ]
    #   where host = { name, ip, mac :: String; dns :: Bool }
    host = lib.mapAttrsToList (name: hostCfg: {
      inherit name;
      inherit (hostCfg) mac;
      ip = hostCfg.addresses.lan;
      dns = true;
    }) lanCfgs;
  };
}
