{ flakeCfg, targetCfg, ... }:
let
  inherit (flakeCfg) fqdns pocketId;
  inherit (targetCfg) headnetPrefixes ports;
in
{
  services = {
    # Caddy terminates TLS, so AdGuard answers DoH over plain HTTP behind it.
    adguardhome.settings.http.doh.insecure_enabled = true;

    caddy.virtualHosts = {
      ${fqdns.adguard}.extraConfig = ''
        @headnet remote_ip ${headnetPrefixes.v4} ${headnetPrefixes.v6}
        handle @headnet {
          forward_auth 127.0.0.1:${toString ports.oauth2-proxy} {
            uri /oauth2/auth?allowed_groups=${pocketId.adminGroup}
            @unauthorized status 401
            handle_response @unauthorized {
              redir * https://${fqdns.auth}/oauth2/start?rd={scheme}://{host}{uri}
            }
          }
          reverse_proxy 127.0.0.1:${toString ports.adguard}
        }
        respond 404
      '';
      ${fqdns.dns}.extraConfig = ''
        handle /dns-query* {
          reverse_proxy 127.0.0.1:${toString ports.adguard}
        }
        respond 404
      '';
    };
  };
}
