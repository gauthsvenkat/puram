{
  config,
  targetCfg,
  lib,
  pkgs,
  ...
}:
let
  inherit (targetCfg) paths;
  inherit (config.sops) placeholder secrets;
in
{
  # Live state runs on the (unmirrored) SSD; nightly copies onto the pool keep
  # it the complete, host-portable source of truth.
  services.postgresqlBackup = {
    enable = true;
    backupAll = true;
    location = "${paths.backups}/postgres";
    startAt = "*-*-* 04:00:00";
  };

  sops.secrets = {
    "restic_password" = { };
    "scaleway_backups_access_key" = { };
    "scaleway_backups_secret_key" = { };
  };

  sops.templates."restic_offsite_env".content = ''
    AWS_ACCESS_KEY_ID=${placeholder."scaleway_backups_access_key"}
    AWS_SECRET_ACCESS_KEY=${placeholder."scaleway_backups_secret_key"}
  '';

  services.restic.backups."offsite" = {
    repository = "s3:https://s3.nl-ams.scw.cloud/backups";
    environmentFile = config.sops.templates."restic_offsite_env".path;
    passwordFile = secrets."restic_password".path;
    initialize = true;
    paths = [
      "${paths.backups}/postgres"
      "${paths.backups}/state"
      "${paths.data}/immich/library"
      "${paths.data}/immich/upload"
      "${paths.data}/paperless-ngx/media/documents/originals"
    ];
    extraOptions = [
      "s3.region=nl-ams"
      "s3.storage-class=ONEZONE_IA"
    ];
    pruneOpts = [
      "--keep-daily 3"
      "--keep-weekly 2"
      "--keep-monthly 1"
    ];
    checkOpts = [ "--read-data-subset=1%" ];
    progressFps = 0.0167;
    timerConfig = {
      OnCalendar = "*-*-* 05:00:00";
      Persistent = true;
    };
  };

  systemd.services."state-backup" = {
    serviceConfig.Type = "oneshot";
    script =
      let
        stateDirs = [
          "/var/lib/jellyfin"
          "/var/lib/private/AdGuardHome"
          "/var/lib/private/vikunja"
          "/var/lib/speedtest-tracker"
        ];
      in
      ''
        ${lib.getExe' pkgs.coreutils "mkdir"} -p ${paths.backups}/state
        ${lib.getExe pkgs.rsync} -a --delete ${lib.escapeShellArgs stateDirs} ${paths.backups}/state/
      '';
  };

  systemd.timers."state-backup" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 04:15:00";
      Persistent = true;
    };
  };
}
