{ flakeCfg, targetCfg, ... }:
let
  inherit (flakeCfg) fqdns;
  inherit (targetCfg) headnetPrefixes ports;
in
{
  services.caddy.virtualHosts = {
    ${fqdns.pocket-id}.extraConfig = ''
      reverse_proxy 127.0.0.1:${toString ports.pocket-id}
    '';
    ${fqdns.auth}.extraConfig = ''
      @headnet remote_ip ${headnetPrefixes.v4} ${headnetPrefixes.v6}
      handle @headnet {
        reverse_proxy 127.0.0.1:${toString ports.oauth2-proxy}
      }
      respond 404
    '';
  };

  # oauth2-proxy won't start while it can't reach its OIDC provider. Pocket ID
  # is considered started when systemd forks it, so setting the ordering alone
  # doesn't fix the race; a longer `RestartSec` retries past the start limit.
  systemd.services.oauth2-proxy = {
    after = [
      "caddy.service"
      "pocket-id.service"
    ];
    wants = [ "pocket-id.service" ];
    serviceConfig.RestartSec = 5;
  };
}
