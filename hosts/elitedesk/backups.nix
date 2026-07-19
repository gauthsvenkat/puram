{
  hostCfg,
  lib,
  pkgs,
  ...
}:
let
  inherit (hostCfg) paths;
  stateDirs = [
    # BEGIN-PRIVATE
    "/var/lib/bazarr"
    # END-PRIVATE
    "/var/lib/jellyfin"
    "/var/lib/private/AdGuardHome"
    # BEGIN-PRIVATE
    "/var/lib/private/seerr"
    # END-PRIVATE
    "/var/lib/private/vikunja"
    # BEGIN-PRIVATE
    "/var/lib/prowlarr"
    "/var/lib/qBittorrent"
    "/var/lib/radarr"
    "/var/lib/sabnzbd"
    "/var/lib/sonarr"
    # END-PRIVATE
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
