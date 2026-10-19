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

  # listToAttrs :: [ { name :: String; value :: service } ] -> { serviceName::String -> service }
  #   where service = { serviceConfig :: { UMask :: String } }
  systemd.services = lib.listToAttrs (
    map (u: {
      name = u;
      value.serviceConfig.UMask = lib.mkForce "0002";
    }) members
  );
}
