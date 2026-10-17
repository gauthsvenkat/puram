{
  targetCfg,
  ...
}:
let
  inherit (targetCfg) paths;
in
{
  services.postgresql.dataDir = paths.postgres;

  # WAL recovery and shutdown checkpoints can need more than the default 2min.
  systemd.services.postgresql.serviceConfig = {
    TimeoutStartSec = "10min";
    TimeoutStopSec = "15min";
  };

  # Postgres's unit hardening binds dataDir into its mount namespace, which
  # refuses to start if the path doesn't exist yet.
  systemd.tmpfiles.rules = [
    "d ${paths.postgres} 0700 postgres postgres - -"
  ];
}
