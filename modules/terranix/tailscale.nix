{ flakeCfg, lib, ... }:
let
  inherit (flakeCfg) homeserver router;
in
{
  data.tailscale_device = {
    ${homeserver}.hostname = homeserver;
    ${router}.hostname = router;
  };

  resource =
    let
      infraTag = "tag:infra";
      routerTag = "tag:router";
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
            dst = [ routerTag ];
            ip = [
              "tcp:53"
              "udp:53"
            ];
          }
          {
            src = [ "autogroup:member" ];
            dst = [ serverTag ];
            ip = [
              "tcp:80"
              "tcp:443"
            ];
          }
        ];
        tagOwners = {
          ${infraTag} = [ "autogroup:owner" ];
          ${routerTag} = [
            "autogroup:owner"
            infraTag
          ];
          ${serverTag} = [
            "autogroup:owner"
            infraTag
          ];
        };
      };

      tailscale_device_tags = {
        ${homeserver} = {
          device_id = lib.tf.ref "data.tailscale_device.${homeserver}.node_id";
          tags = [ serverTag ];
        };
        ${router} = {
          device_id = lib.tf.ref "data.tailscale_device.${router}.node_id";
          tags = [ routerTag ];
        };
      };

      tailscale_dns_configuration."tailnet" = {
        magic_dns = true;
        override_local_dns = true;
        search_paths = [ ];
        nameservers = [ { address = lib.tf.ref "data.tailscale_device.${router}.addresses[0]"; } ];
      };

      # NOTE: tofu's own credentials.
      tailscale_oauth_client."opentofu" = {
        description = "opentofu";
        scopes = [
          "devices:core"
          "dns"
          "oauth_keys"
          "policy_file"
        ];
        tags = [ infraTag ];
        lifecycle.create_before_destroy = true;
      };
    };

  output = {
    tailscale_oauth_client_id = {
      value = lib.tf.ref "tailscale_oauth_client.opentofu.id";
      sensitive = true;
    };
    tailscale_oauth_client_secret = {
      value = lib.tf.ref "tailscale_oauth_client.opentofu.key";
      sensitive = true;
    };
  };
}
