{ lib, ... }:
let
  group = "media";
  members = [
    "jellyfin"
  ];
in
{
  users.groups.${group}.gid = 169;

  services = builtins.listToAttrs (
    map (u: {
      name = u;
      value = { inherit group; };
    }) members
  );

  systemd.services = builtins.listToAttrs (
    map (u: {
      name = u;
      value.serviceConfig.UMask = lib.mkForce "0002";
    }) members
  );
}
