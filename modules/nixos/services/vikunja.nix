{
  config,
  flakeCfg,
  targetCfg,
  ...
}:
let
  inherit (flakeCfg) domain;
  cfg = config.services.vikunja;
  inherit (config.sops) placeholder;
in
{
  sops.secrets."vikunja_jwt_secret" = { };

  # Without a fixed secret vikunja generates one per start, logging everyone
  # out on every restart.
  sops.templates."vikunja_env" = {
    restartUnits = [ "vikunja.service" ];
    content = "VIKUNJA_SERVICE_SECRET=${placeholder."vikunja_jwt_secret"}\n";
  };

  services = {
    vikunja = {
      enable = true;
      inherit (targetCfg.ports.vikunja) port;
      frontendScheme = "https";
      frontendHostname = "vikunja.${domain}";
      database = {
        type = "postgres";
        # Unix socket -> peer auth as the dynamic `vikunja` user, no password.
        host = "/run/postgresql";
      };
      environmentFiles = [ config.sops.templates."vikunja_env".path ];
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
