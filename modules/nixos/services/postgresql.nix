{
  hostCfg,
  ...
}:
let
  inherit (hostCfg) paths;
in
{
  services.postgresql.dataDir = paths.postgres;

  # Postgres's unit hardening binds dataDir into its mount namespace, which
  # refuses to start if the path doesn't exist yet.
  systemd.tmpfiles.rules = [
    "d ${paths.postgres} 0700 postgres postgres - -"
  ];
}
