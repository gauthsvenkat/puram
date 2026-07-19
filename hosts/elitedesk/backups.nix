{
  hostCfg,
  lib,
  pkgs,
  ...
}:
let
  inherit (hostCfg) paths;
  stateDirs = [
    "/var/lib/jellyfin"
    "/var/lib/private/AdGuardHome"
    "/var/lib/private/vikunja"
    "/var/lib/speedtest-tracker"
  ];
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

  systemd.services.state-backup = {
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p ${paths.backups}/state
      ${lib.getExe pkgs.rsync} -a --delete ${lib.escapeShellArgs stateDirs} ${paths.backups}/state/
    '';
  };

  systemd.timers.state-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 04:15:00";
      Persistent = true;
    };
  };
}
