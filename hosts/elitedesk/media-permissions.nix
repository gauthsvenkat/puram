{ lib, ... }:
let
  group = "media";
  members = [
    # BEGIN-PRIVATE
    "bazarr"
    # END-PRIVATE
    "jellyfin"
    # BEGIN-PRIVATE
    "qbittorrent"
    "radarr"
    "sabnzbd"
    "sonarr"
    # END-PRIVATE
  ];
in
{
  # BEGIN-PRIVATE
  # gid 169 follows nixarr's convention.
  # END-PRIVATE
  users.groups.${group}.gid = 169;

  services = lib.listToAttrs (
    map (u: {
      name = u;
      value = { inherit group; };
    }) members
  );

  # BEGIN-PRIVATE
  # UMask=0002 keeps group-write on files (0664) and dirs (0775) the
  # service creates. mkForce because servarr modules hardcode 0022 and
  # jellyfin hardcodes 0077. We trade jellyfin's defensive hardening
  # for a uniform stack-wide policy.
  # END-PRIVATE
  systemd.services = lib.listToAttrs (
    map (u: {
      name = u;
      value.serviceConfig.UMask = lib.mkForce "0002";
    }) members
  );
}
