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
    ociDomain
    router
    ;
  inherit (targetCfg) dnsServer;
  inherit (targetCfg.cloudflare) accountId;
  inherit (targetCfgs.nixos.${homeserver}) tailnetIp;
  controlServerIp = targetCfgs.nixos.${controlServer}.tailnetIp;
in
{
  resource =
    let
      zoneId = lib.tf.ref "cloudflare_zone.example_com.id";
    in
    {
      cloudflare_zone."example_com" = {
        account.id = accountId;
        name = domain;
        type = "full";
      };

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

          "caddy_dns" = mkDnsToken "caddy-acme-${homeserver}";

          "caddy_dns_headscale" = mkDnsToken "caddy-acme-${controlServer}";

          "caddy_dns_${dnsServer}" = mkDnsToken "caddy-acme-${dnsServer}";

          "ddns" = mkDnsToken "ddns-${router}";

        };

      cloudflare_dns_record = {
        "${ddnsName}" = {
          zone_id = zoneId;
          name = "${ddnsName}.${domain}";
          type = "A";
          # Placeholder IP; the router's DDNS updates it, so tofu must ignore changes to it.
          content = "192.0.2.1";
          lifecycle.ignore_changes = [ "content" ];
          proxied = false;
          ttl = 1;
        };

        "dns" = {
          zone_id = zoneId;
          name = "dns.${domain}";
          type = "CNAME";
          content = "${dnsServer}.${ociDomain}";
          proxied = false;
          ttl = 1;
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

        "${dnsServer}_ipv4" = {
          zone_id = zoneId;
          name = "${dnsServer}.${ociDomain}";
          type = "A";
          content = lib.tf.ref "oci_core_public_ip.sentinel.ip_address";
          proxied = false;
          ttl = 1;
        };
        "${dnsServer}_ipv6" = {
          zone_id = zoneId;
          name = "${dnsServer}.${ociDomain}";
          type = "AAAA";
          content = lib.tf.ref "data.oci_core_vnic.sentinel.ipv6addresses[0]";
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

    };

  output = {
    cloudflare_dns_token_dns = {
      value = lib.tf.ref "cloudflare_account_token.caddy_dns_${dnsServer}.value";
      sensitive = true;
    };
    cloudflare_dns_token_headscale = {
      value = lib.tf.ref "cloudflare_account_token.caddy_dns_headscale.value";
      sensitive = true;
    };
    cloudflare_dns_token_homeserver = {
      value = lib.tf.ref "cloudflare_account_token.caddy_dns.value";
      sensitive = true;
    };
    cloudflare_dns_token_router = {
      value = lib.tf.ref "cloudflare_account_token.ddns.value";
      sensitive = true;
    };
  };
}
