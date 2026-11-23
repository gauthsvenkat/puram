{ flakeCfg, targetCfg, ... }:
let
  inherit (flakeCfg) fqdns;
  inherit (targetCfg) ports;
in
{
  services.caddy.virtualHosts.${fqdns.ntfy}.extraConfig = ''
    reverse_proxy 127.0.0.1:${toString ports.ntfy}
  '';
}
