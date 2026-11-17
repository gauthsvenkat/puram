{
  flakeCfg,
  targetCfg,

  config,
  ...
}:
let
  inherit (flakeCfg) fqdns pocketId;
  inherit (targetCfg) ports;
  inherit (config.sops) secrets;
  inherit (config.services.headscale) user;
in
{
  sops.secrets =
    let
      owner = user;
      restartUnits = [ "headplane.service" ];
    in
    {
      "headscale/headplane_cookie_secret" = {
        sopsFile = ../../../secrets/headscale.yaml;
        key = "headplane_cookie_secret";
        inherit owner restartUnits;
      };
      "headscale/headscale_headplane_api_key" = {
        sopsFile = ../../../secrets/headscale.yaml;
        key = "headscale_headplane_api_key";
        inherit owner restartUnits;
      };
      "pocket-id/pocket_id_headplane_client_secret" = {
        sopsFile = ../../../secrets/pocket-id.yaml;
        key = "pocket_id_headplane_client_secret";
        inherit owner restartUnits;
      };
    };

  services.headplane = {
    enable = true;
    settings = {
      server = {
        base_url = "https://${fqdns.headplane}";
        cookie_secret_path = secrets."headscale/headplane_cookie_secret".path;
        port = ports.headplane;
      };
      headscale.api_key_path = secrets."headscale/headscale_headplane_api_key".path;
      oidc = {
        issuer = "https://${fqdns.pocket-id}";
        client_id = pocketId.clientIds.headplane;
        client_secret_path = secrets."pocket-id/pocket_id_headplane_client_secret".path;
        use_pkce = true;
        disable_api_key_login = true;
      };
    };
  };

  systemd.services.headplane.wantedBy = [ "headscale.service" ];
}
