{
  flakeCfg,
  targetCfg,

  config,
  ...
}:
let
  inherit (flakeCfg) fqdns;
  inherit (targetCfg) ports;
  inherit (config.sops) secrets;
  cfg = config.services.pocket-id;
in
{
  sops.secrets =
    let
      sopsFile = ../../../secrets/pocket-id.yaml;
      restartUnits = [ "pocket-id.service" ];
    in
    {
      "pocket-id/pocket_id_encryption_key" = {
        inherit restartUnits sopsFile;
        key = "pocket_id_encryption_key";
      };
      "pocket-id/pocket_id_static_api_key" = {
        inherit restartUnits sopsFile;
        key = "pocket_id_static_api_key";
      };
    };

  services.pocket-id = {
    enable = true;
    credentials = {
      ENCRYPTION_KEY = secrets."pocket-id/pocket_id_encryption_key".path;
      STATIC_API_KEY = secrets."pocket-id/pocket_id_static_api_key".path;
    };
    settings =
      let
        host = "127.0.0.1";
      in
      {
        APP_URL = "https://${fqdns.pocket-id}";
        # Pocket ID's default, made explicit so the litestream backup can read the same path.
        DB_CONNECTION_STRING = "${cfg.dataDir}/data/pocket-id.db";
        # logos, profile pictures, etc. go into the database too, so backing it up covers everything.
        # https://pocket-id.org/docs/configuration/environment-variables#database-and-file-storage
        FILE_BACKEND = "database";
        HOST = host;
        PORT = ports.pocket-id;
        # Take the client IP from `X-Forwarded-For`; safe since it will be behind Caddy.
        # https://pocket-id.org/docs/setup/reverse-proxy
        TRUST_PROXY = true;
        # The internal task runtime (UDP).
        # https://pocket-id.org/docs/configuration/environment-variables#other
        ACTORS_HOST = host;
        # Nothing identifiable is sent, so analytics is allowed
        # https://pocket-id.org/docs/configuration/analytics
        ANALYTICS_DISABLED = false;
        UI_CONFIG_DISABLED = true;
        ALLOW_USER_SIGNUPS = "withToken";
      };
  };
}
