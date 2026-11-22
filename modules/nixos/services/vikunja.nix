{
  flakeCfg,
  targetCfg,

  config,
  ...
}:
let
  inherit (flakeCfg) domains;
  inherit (targetCfg) ports;
  inherit (config.sops) placeholder templates;
  cfg = config.services.vikunja;
in
{
  sops = {
    secrets."vikunja_jwt_secret" = { };

    # Without a fixed secret vikunja generates one per start, logging everyone
    # out on every restart.
    templates."vikunja_env" = {
      content = "VIKUNJA_SERVICE_SECRET=${placeholder."vikunja_jwt_secret"}\n";
      restartUnits = [ "vikunja.service" ];
    };
  };

  services = {
    vikunja = {
      enable = true;
      database = {
        type = "postgres";
        # Unix socket -> peer auth as the dynamic `vikunja` user, no password.
        host = "/run/postgresql";
      };
      environmentFiles = [ templates."vikunja_env".path ];
      frontendHostname = "vikunja.${domains.apex}";
      frontendScheme = "https";
      port = ports.vikunja;
    };

    postgresql = {
      ensureDatabases = [ cfg.database.database ];
      ensureUsers = [
        {
          name = cfg.database.user;
          ensureDBOwnership = true;
        }
      ];
    };
  };
}
