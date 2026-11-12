{
  targetCfg,

  targetCfgs,

  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (targetCfg) offsiteBucket paths;
  inherit (targetCfgs.terranix."infra".scaleway) region;
  inherit (config.sops) placeholder secrets templates;
in
{
  sops = {
    secrets = {
      "restic_password" = { };
      "scaleway_access_key" = { };
      "scaleway_secret_key" = { };
    };

    templates."restic_offsite_env".content = ''
      AWS_ACCESS_KEY_ID=${placeholder."scaleway_access_key"}
      AWS_SECRET_ACCESS_KEY=${placeholder."scaleway_secret_key"}
    '';
  };

  # Live state runs on the (unmirrored) SSD. This was done because the
  # pool's USB SMR disks stall on random sync writes (sqlite, Postgres).
  # Nightly copies onto the pool keep it backed up.
  systemd = {
    services."state-backup" = {
      script =
        let
          stateDirs = [
            "/var/lib/jellyfin"
            "/var/lib/private/vikunja"
            "/var/lib/speedtest-tracker"
          ];
        in
        ''
          ${lib.getExe' pkgs.coreutils "mkdir"} -p ${paths.backups}/state
          ${lib.getExe pkgs.rsync} -a --delete ${lib.escapeShellArgs stateDirs} ${paths.backups}/state/
        '';
      serviceConfig.Type = "oneshot";
    };

    timers."state-backup" = {
      timerConfig = {
        OnCalendar = "*-*-* 04:15:00";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
  };

  services = {
    postgresqlBackup = {
      enable = true;
      backupAll = true;
      location = "${paths.backups}/postgres";
      startAt = "*-*-* 04:00:00";
    };

    restic.backups."offsite" = {
      repository = "s3:https://s3.${region}.scw.cloud/${offsiteBucket}";
      environmentFile = templates."restic_offsite_env".path;
      passwordFile = secrets."restic_password".path;
      checkOpts = [ "--read-data-subset=1%" ];
      extraOptions = [
        "s3.region=${region}"
        "s3.storage-class=ONEZONE_IA"
      ];
      initialize = true;
      paths = [
        "${paths.backups}/postgres"
        "${paths.backups}/state"
        "${paths.data}/immich/library"
        "${paths.data}/immich/upload"
        "${paths.data}/paperless-ngx/media/documents/originals"
      ];
      progressFps = 0.0167;
      pruneOpts = [
        "--keep-daily 3"
        "--keep-weekly 2"
        "--keep-monthly 1"
      ];
      timerConfig = {
        OnCalendar = "*-*-* 05:00:00";
        Persistent = true;
      };
    };
  };
}
