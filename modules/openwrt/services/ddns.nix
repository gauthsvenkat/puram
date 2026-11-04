{ flakeCfg, ... }:
let
  inherit (flakeCfg) ddnsName domain;
in
{
  packages = [
    "ddns-scripts"
    "ddns-scripts-cloudflare"
  ];

  uci.settings.ddns.service."${ddnsName}" = {
    enabled = true;
    service_name = "cloudflare.com-v4";

    username = "Bearer";
    password._secret = "cloudflare_ddns_token";

    domain = "${ddnsName}@${domain}";
    lookup_host = "${ddnsName}.${domain}";
  };
}
