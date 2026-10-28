{
  flakeCfg,
  targetCfgs,
  lib,
  ...
}:
let
  inherit (flakeCfg)
    dns
    homeserver
    lanDomain
    router
    ;
  routerCfg = targetCfgs.openwrt.${router};
in
{
  data.tailscale_device.${homeserver}.hostname = homeserver;

  resource =
    let
      infraTag = "tag:infra";
      serverTag = "tag:server";
    in
    {
      # NOTE: Applying replaces the whole console policy; console edits get overwritten.
      tailscale_acl."tailnet".acl = lib.toJSON {
        grants = [
          {
            src = [ "autogroup:owner" ];
            dst = [ "*" ];
            ip = [ "*" ];
          }
          {
            src = [ "autogroup:member" ];
            dst = [ "autogroup:self" ];
            ip = [ "*" ];
          }
          {
            src = [ "autogroup:member" ];
            dst = [ serverTag ];
            ip = [
              "tcp:53"
              "tcp:80"
              "tcp:443"
              "udp:53"
            ];
          }
        ];
        tagOwners = {
          ${infraTag} = [ "autogroup:owner" ];
          ${serverTag} = [
            "autogroup:owner"
            infraTag
          ];
        };
      };

      tailscale_device_tags.${homeserver} = {
        device_id = lib.tf.ref "data.tailscale_device.${homeserver}.node_id";
        tags = [ serverTag ];
      };

      tailscale_dns_configuration."tailnet" = {
        magic_dns = true;
        override_local_dns = true;
        search_paths = [ ];
        nameservers = [ { address = dns.tailnetIp; } ];
        split_dns = [
          {
            domain = lanDomain;
            nameservers = [ { address = routerCfg.lan.ip; } ];
          }
        ];
      };
    };
}
