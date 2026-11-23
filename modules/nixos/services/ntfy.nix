{
  flakeCfg,
  targetCfg,

  config,
  ...
}:
let
  inherit (flakeCfg) fqdns;
  inherit (targetCfg) ports;
  inherit (config) sops;
in
{
  sops = {
    secrets."ntfy/ntfy_auth_users" = {
      sopsFile = ../../../secrets/ntfy.yaml;
      key = "ntfy_auth_users";
    };
    templates."ntfy_env" = {
      content = ''
        NTFY_AUTH_USERS='${sops.placeholder."ntfy/ntfy_auth_users"}'
      '';
      restartUnits = [ "ntfy-sh.service" ];
    };
  };

  services.ntfy-sh = {
    enable = true;
    environmentFile = sops.templates."ntfy_env".path;
    settings = {
      auth-default-access = "deny-all";
      base-url = "https://${fqdns.ntfy}";
      behind-proxy = true;
      listen-http = "127.0.0.1:${toString ports.ntfy}";
      upstream-base-url = "https://ntfy.sh";
    };
  };
}
