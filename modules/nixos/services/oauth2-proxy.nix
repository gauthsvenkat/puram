{
  flakeCfg,
  targetCfg,

  config,
  ...
}:
let
  inherit (flakeCfg) domains fqdns pocketId;
  inherit (targetCfg) ports;
  inherit (config.sops) secrets;
in
{
  sops.secrets =
    let
      sopsFile = ../../../secrets/pocket-id.yaml;
      restartUnits = [ "oauth2-proxy.service" ];
    in
    {
      "pocket-id/oauth2_proxy_cookie_secret" = {
        inherit restartUnits sopsFile;
        key = "oauth2_proxy_cookie_secret";
      };
      "pocket-id/pocket_id_oauth2_proxy_client_secret" = {
        inherit restartUnits sopsFile;
        key = "pocket_id_oauth2_proxy_client_secret";
      };
    };

  # See https://oauth2-proxy.github.io/oauth2-proxy/configuration/overview
  # for more context on the following settings.
  services.oauth2-proxy =
    let
      subdomains = ".${domains.apex}";
    in
    {
      enable = true;
      provider = "oidc";
      oidcIssuerUrl = "https://${fqdns.pocket-id}";
      clientID = pocketId.clientIds.oauth2-proxy;
      clientSecretFile = secrets."pocket-id/pocket_id_oauth2_proxy_client_secret".path;
      scope = "openid email profile groups";
      httpAddress = "http://127.0.0.1:${toString ports.oauth2-proxy}";
      redirectURL = "https://${fqdns.auth}/oauth2/callback";
      cookie = {
        domain = subdomains;
        secretFile = secrets."pocket-id/oauth2_proxy_cookie_secret".path;
      };
      email.domains = [ "*" ];
      reverseProxy = true;
      trustedProxyIP = [ "127.0.0.1/32" ];
      setXauthrequest = true;
      upstream = [ "static://202" ];
      extraConfig = {
        code-challenge-method = "S256";
        skip-provider-button = true;
        whitelist-domain = subdomains;
      };
    };
}
