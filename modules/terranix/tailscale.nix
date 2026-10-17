{ allTargetCfgs, lib, ... }:
let
  inherit (allTargetCfgs.elitedesk) tailnetIp;
in
{
  data.tailscale_device.elitedesk.hostname = "elitedesk";

  resource =
    let
      serverTag = "tag:server";
    in
    {
      tailscale_acl.tailnet.acl = lib.toJSON {
        # Allow all connections.
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

      tailscale_device_tags.elitedesk = {
        device_id = lib.tf.ref "data.tailscale_device.elitedesk.node_id";
        tags = [ serverTag ];
      };

      tailscale_dns_configuration.tailnet = {
        magic_dns = true;
        override_local_dns = true;
        search_paths = [ ];
        nameservers = [
          { address = tailnetIp; }
          { address = "1.1.1.1"; }
          { address = "9.9.9.9"; }
        ];
        # API returns nameservers as an unordered set; ignore phantom reorder diffs.
        # To change the list deliberately: comment this out for one apply.
        lifecycle.ignore_changes = [ "nameservers" ];
      };
    };
}
