{ allTargetCfgs, lib, ... }:
let
  inherit (allTargetCfgs."elitedesk") tailnetIp;
  router = allTargetCfgs."flint-2";
in
{
  data.tailscale_device."elitedesk".hostname = "elitedesk";

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

      tailscale_device_tags."elitedesk" = {
        device_id = lib.tf.ref "data.tailscale_device.elitedesk.node_id";
        tags = [ serverTag ];
      };

      tailscale_dns_configuration."tailnet" = {
        magic_dns = true;
        override_local_dns = true;
        search_paths = [ ];
        nameservers = [ { address = tailnetIp; } ];
        split_dns = [
          {
            domain = "lan";
            nameservers = [ { address = router.lan.ip; } ];
          }
        ];
      };
    };
}
