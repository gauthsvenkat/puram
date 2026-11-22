{
  flakeCfg,
  targetCfg,

  targetCfgs,

  lib,
  ...
}:
let
  inherit (flakeCfg) domains fqdns servers;
  inherit (targetCfg) ports;
  homeserverIp = targetCfgs.nixos.${servers.home}.addresses.lan;
  # map :: (domain::String -> server::String) -> [ domain::String ] -> [ server::String ]
  # :: [ server::String ], names under `domains.apex` that are not on the homeserver, sent upstream
  upstreamServers = map (name: "/${name}/#") (
    lib.attrValues fqdns
    ++ [
      domains.headnet
      domains.oci
    ]
  );
  # filterAttrs :: (hostname::String -> targetCfg -> Bool) -> { hostname::String -> targetCfg } -> { hostname::String -> targetCfg }
  # :: { hostname::String -> targetCfg }, hosts with a LAN address
  lanCfgs = lib.filterAttrs (_: hostCfg: hostCfg ? addresses.lan) targetCfgs.nixos;
in
{
  uci.settings.dhcp = {
    dnsmasq = [
      {
        address = [ "/${domains.apex}/${homeserverIp}" ];
        authoritative = true;
        cachesize = 1000;
        # dnsmasq answers `domains.lan` itself and forwards the rest to AdGuard Home.
        domain = domains.lan;
        domainneeded = true;
        expandhosts = true;
        local = "/${domains.lan}/";
        localise_queries = true;
        localservice = false;
        noresolv = true;
        readethers = true;
        rebind_domain = [ domains.apex ];
        rebind_localhost = true;
        # `strictorder`: AdGuard Home over DoH through https-dns-proxy; the public
        # resolvers only answer if it is down.
        server = [
          "127.0.0.1#${toString ports.doh}"
          "9.9.9.9"
          "1.1.1.1"
        ]
        ++ upstreamServers;
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
