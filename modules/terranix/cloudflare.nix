{
  flakeCfg,
  targetCfg,

  targetCfgs,

  lib,
  ...
}:
let
  inherit (flakeCfg)
    controlServer
    ddnsName
    domain
    homeserver
    router
    ;
  inherit (targetCfgs.nixos.${homeserver}) tailnetIp;
  controlServerIp = targetCfgs.nixos.${controlServer}.tailnetIp;
  inherit (targetCfg.cloudflare) accountId;
in
{
  resource =
    let
      zoneId = lib.tf.ref "cloudflare_zone.example_com.id";
    in
    {
      # The resource `cloudflare_api_token` only manages user-owned ones.
      # So, we use resource `cloudflare_account_token`.
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
          zoneDnsPolicy = {
            effect = "allow";
            permission_groups = [
              permissionGroups.dnsWrite
              permissionGroups.zoneRead
            ];
            resources = scopes.zone;
          };
          mkDnsToken = name: {
            account_id = accountId;
            inherit name;
            policies = [ zoneDnsPolicy ];
          };
        in
        {
          "caddy_dns" = mkDnsToken "caddy-acme-${homeserver}";

          "caddy_dns_headscale" = mkDnsToken "caddy-acme-${controlServer}";

          "ddns" = mkDnsToken "ddns-${router}";

          "opentofu" = {
            account_id = accountId;
            name = "opentofu-infra";
            policies = [
              {
                effect = "allow";
                permission_groups = [ permissionGroups.accountApiTokensWrite ];
                resources = scopes.account;
              }
              zoneDnsPolicy
            ];
          };
        };

      cloudflare_dns_record = {
        "${ddnsName}" = {
          zone_id = zoneId;
          name = "${ddnsName}.${domain}";
          type = "A";
          # Placeholder IP; the router's DDNS updates it, so tofu must ignore changes to it.
          content = "192.0.2.1";
          proxied = false;
          ttl = 1;
          lifecycle.ignore_changes = [ "content" ];
        };

        "headplane" = {
          zone_id = zoneId;
          name = "headplane.${domain}";
          type = "A";
          content = controlServerIp;
          proxied = false;
          ttl = 1;
        };

        "headscale" = {
          zone_id = zoneId;
          name = "headscale.${domain}";
          type = "CNAME";
          content = "${ddnsName}.${domain}";
          proxied = false;
          ttl = 1;
        };

        "wildcard" = {
          zone_id = zoneId;
          name = "*.${domain}";
          type = "A";
          content = tailnetIp;
          # Never proxy (orange cloud); the tailnet IP is unreachable from the public internet.
          proxied = false;
          ttl = 1;
        };
      };

      cloudflare_zone."example_com" = {
        account.id = accountId;
        name = domain;
        type = "full";
      };
    };

  output = {
    cloudflare_dns_token_homeserver = {
      value = lib.tf.ref "cloudflare_account_token.caddy_dns.value";
      sensitive = true;
    };
    cloudflare_dns_token_headscale = {
      value = lib.tf.ref "cloudflare_account_token.caddy_dns_headscale.value";
      sensitive = true;
    };
    cloudflare_dns_token_router = {
      value = lib.tf.ref "cloudflare_account_token.ddns.value";
      sensitive = true;
    };
  };
}
