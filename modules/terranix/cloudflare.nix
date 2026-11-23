{
  flakeCfg,
  targetCfg,

  targetCfgs,

  lib,
  ...
}:
let
  inherit (flakeCfg)
    domains
    fqdns
    servers
    ;
  inherit (targetCfg.cloudflare) accountId;
  controlServerIp = targetCfgs.nixos.${servers.control}.addresses.headnet;
  dnsServerIp = targetCfgs.nixos.${servers.dns}.addresses.headnet;
  homeserverIp = targetCfgs.nixos.${servers.home}.addresses.headnet;
in
{
  variable."cloudflare_api_token".sensitive = true;

  provider.cloudflare.api_token = lib.tf.ref "var.cloudflare_api_token";

  resource =
    let
      zoneId = lib.tf.ref "cloudflare_zone.gauthsvenkat_dev.id";
    in
    {
      cloudflare_zone."gauthsvenkat_dev" = {
        account.id = accountId;
        name = domains.apex;
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

          "caddy_dns_${servers.dns}" = mkDnsToken "caddy-acme-${servers.dns}";
        };

      cloudflare_dns_record =
        let
          mkRecord = name: type: content: {
            zone_id = zoneId;
            inherit content name type;
            # DNS only (grey cloud): clients connect to the host directly, and Cloudflare can't reach headnet IPs.
            proxied = false;
            # Automatic, Usually 300s for DNS-only records.
            # https://developers.cloudflare.com/dns/manage-dns-records/reference/ttl/
            ttl = 1;
          };
        in
        {
          "${servers.dns}_ipv4" = mkRecord "${servers.dns}.${domains.oci}" "A" (
            lib.tf.ref "oci_core_public_ip.sentinel.ip_address"
          );
          "${servers.dns}_ipv6" = mkRecord "${servers.dns}.${domains.oci}" "AAAA" (
            lib.tf.ref "data.oci_core_vnic.sentinel.ipv6addresses[0]"
          );

          "dns" = mkRecord fqdns.dns "CNAME" "${servers.dns}.${domains.oci}";
          "headscale" = mkRecord fqdns.headscale "CNAME" "${servers.control}.${domains.oci}";
          "ntfy" = mkRecord fqdns.ntfy "CNAME" "${servers.control}.${domains.oci}";
          "pocket-id" = mkRecord fqdns.pocket-id "CNAME" "${servers.control}.${domains.oci}";

          "adguard" = mkRecord fqdns.adguard "A" dnsServerIp;
          "auth" = mkRecord fqdns.auth "A" controlServerIp;
          "headplane" = mkRecord fqdns.headplane "A" controlServerIp;
          "wildcard" = mkRecord "*.${domains.apex}" "A" homeserverIp;
        };
    };

  output."dns" = {
    value."cloudflare_dns_token" = lib.tf.ref "cloudflare_account_token.caddy_dns_${servers.dns}.value";
    sensitive = true;
  };
}
