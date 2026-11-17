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
}
