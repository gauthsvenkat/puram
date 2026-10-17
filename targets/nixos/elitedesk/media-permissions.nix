{ lib, ... }:
let
  group = "media";
  members = [
    "jellyfin"
  ];
in
{
  users.groups.${group}.gid = 169;

  # listToAttrs :: [ { name :: String; value :: { group :: String } } ] -> { serviceName::String -> { group :: String } }
  services = lib.listToAttrs (
    map (u: {
      name = u;
      value = { inherit group; };
    }) members
  );

  systemd.services = lib.listToAttrs (
    map (u: {
      name = u;
      value.serviceConfig.UMask = lib.mkForce "0002";
    }) members
  );
}
