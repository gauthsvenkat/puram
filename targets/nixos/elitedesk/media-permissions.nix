{ lib, ... }:
let
  group = "media";
  members = [
    "jellyfin"
    # BEGIN-PRIVATE
    "bazarr"
    "qbittorrent"
    "radarr"
    "sabnzbd"
    "sonarr"
    # END-PRIVATE
  ];
in
{
  # BEGIN-PRIVATE
  # NOTE: After a fresh install, fix the existing tree once, then restart `members`:
  #   chgrp -R media /dontdie/data/entertainment
  #   chmod 2775 /dontdie/data/entertainment  (`fd` skips its search root)
  #   fd -HI -t d . /dontdie/data/entertainment -X chmod 2775
  #   fd -HI -t f . /dontdie/data/entertainment -X chmod 0664

  # gid 169 follows nixarr's convention.
  # END-PRIVATE
  users.groups.${group}.gid = 169;

  # listToAttrs :: [ { name :: String; value :: { group :: String } } ] -> { serviceName::String -> { group :: String } }
  services = lib.listToAttrs (
    map (u: {
      name = u;
      value = { inherit group; };
    }) members
  );

  # BEGIN-PRIVATE
  # `UMask=0002` keeps group-write on files (`0664`) and dirs (`0775`) the
  # service creates. `mkForce` because servarr modules hardcode `0022` and
  # jellyfin hardcodes `0077`. We trade jellyfin's defensive hardening
  # for a uniform stack-wide policy.
  # END-PRIVATE
  # listToAttrs :: [ { name :: String; value :: service } ] -> { serviceName::String -> service }
  #   where service = { serviceConfig :: { UMask :: String } }
  systemd.services = lib.listToAttrs (
    map (u: {
      name = u;
      value.serviceConfig.UMask = lib.mkForce "0002";
    }) members
  );
}
