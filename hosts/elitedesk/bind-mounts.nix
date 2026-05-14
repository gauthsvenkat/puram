{
  hostCfg,
  ...
}:
let
  inherit (hostCfg) paths zpool;
in
{
  # BEGIN-PRIVATE
  # AdGuard Home and Seerr run with `DynamicUser=true`, which makes systemd
  # redirect their StateDirectory to /var/lib/private/<name> (a root-only
  # parent that guards against UID recycling). Sabnzbd and qBittorrent use
  # static User= accounts, so their StateDirectory lands at /var/lib/<name>
  # directly. Bind under the path each service actually uses.
  # END-PRIVATE
  fileSystems =
    let
      bind = device: {
        inherit device;
        fsType = "none";
        options = [ "bind" ];
        depends = [ "/${zpool}" ];
      };
    in
    {
      "/var/lib/private/AdGuardHome" = bind "${paths.config}/adguard-home";
      # BEGIN-PRIVATE
      "/var/lib/private/seerr" = bind "${paths.config}/seerr";
      "/var/lib/sabnzbd" = bind "${paths.config}/sabnzbd";
      "/var/lib/qBittorrent" = bind "${paths.config}/qbittorrent";
      # END-PRIVATE
    };
}
