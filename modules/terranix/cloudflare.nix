{
  allTargetCfgs,
  targetCfg,
  lib,
  ...
}:
let
  inherit (allTargetCfgs.elitedesk) domain tailnetIp;
  inherit (targetCfg.cloudflare) accountId;
  zoneId = lib.tf.ref "cloudflare_zone.example_com.id";
in
{
  resource = {
    cloudflare_account_token =
      let
        permissionGroups = {
          accountApiTokensWrite.id = "5bc3f8b21c554832afc660159ab75fa4";
          dnsWrite.id = "4755a26eedb94da69e1066d98aa820be";
          zoneRead.id = "c8fed203ed3043cba015a93ad1616f1f";
        };
        # The provider wants `resources` as a JSON string. The zone id is a
        # tofu reference, so it stays an expression inside that string and
        # is resolved at plan time.
        scopes = {
          account = lib.toJSON { "com.cloudflare.api.account.${accountId}" = "*"; };
          zone = lib.toJSON { "com.cloudflare.api.account.zone.${zoneId}" = "*"; };
        };
      in
      {
        caddy_dns = {
          account_id = accountId;
          name = "caddy-acme-elitedesk";
          policies = [
            {
              effect = "allow";
              permission_groups = [
                permissionGroups.dnsWrite
                permissionGroups.zoneRead
              ];
              resources = scopes.zone;
            }
          ];
        };

        opentofu = {
          account_id = accountId;
          name = "opentofu-infra";
          policies = [
            {
              effect = "allow";
              permission_groups = [ permissionGroups.accountApiTokensWrite ];
              resources = scopes.account;
            }
            {
              effect = "allow";
              permission_groups = [
                permissionGroups.dnsWrite
                permissionGroups.zoneRead
              ];
              resources = scopes.zone;
            }
          ];
          # replacing this token must create the successor before revoking the
          # credential the apply itself is running on
          lifecycle.create_before_destroy = true;
        };
      };

    cloudflare_dns_record.wildcard = {
      zone_id = zoneId;
      name = "*.${domain}";
      type = "A";
      content = tailnetIp;
      proxied = false;
      ttl = 1;
    };

    cloudflare_zone.example_com = {
      account.id = accountId;
      name = domain;
      type = "full";
    };
  };
}
