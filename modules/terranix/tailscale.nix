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
      serverTag = "tag:server";
    in
    {
      # NOTE: Applying replaces the whole console policy; console edits get overwritten.
      tailscale_acl."tailnet".acl = lib.toJSON {
        # Allow all connections by default.
        grants = [
          {
            src = [ "*" ];
            dst = [ "*" ];
            ip = [ "*" ];
          }
        ];
        # Allow all users to SSH into their own devices in check mode.
        ssh = [
          {
            action = "check";
            src = [ "autogroup:member" ];
            dst = [ "autogroup:self" ];
            users = [
              "autogroup:nonroot"
              "root"
            ];
          }
        ];
        # Tags and who may apply them (admins can always apply any tag).
        tagOwners.${serverTag} = [ "autogroup:admin" ];
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
