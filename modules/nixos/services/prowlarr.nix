{
  config,
  targetCfg,
  lib,
  ...
}:
let
  inherit (targetCfg) paths;
  inherit (targetCfg.ports.prowlarr) port;
  dataDir = "${paths.config}/prowlarr";
  user = "prowlarr";
  group = "prowlarr";
in
{
  services.prowlarr = {
    enable = true;
    settings.server.port = port;
    # dataDir is intentionally left at the module default
    # (/var/lib/prowlarr) so the upstream module's tmpfiles + bind-mount
    # entries (both gated on a custom dataDir) stay inert. We point
    # prowlarr at our ZFS path directly via the ExecStart override below.
  };

  # Static user + group with the same name as the unit. Once defined,
  # the User=/Group= override below resolves to a real account and
  # neuters the upstream module's DynamicUser=true. Pattern lifted from
  # nixarr's prowlarr module (github:nix-media-server/nixarr) -- without
  # it, DynamicUser + a custom dataDir + the module's tmpfiles d-rule
  # interact such that every activation re-asserts dataDir as root:root
  # 0700 while StateDirectory= refuses to chown across the bind-mount,
  # eventually leaving prowlarr unable to traverse its own data dir.
  users.users.${user} = {
    isSystemUser = true;
    inherit group;
  };
  users.groups.${group} = { };

  systemd.services.prowlarr.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = lib.mkForce user;
    Group = lib.mkForce group;
    # Avoid creating an unused /var/lib/prowlarr placeholder; prowlarr
    # reads/writes its state directly at ${dataDir} on ZFS.
    StateDirectory = lib.mkForce "";
    ExecStart = lib.mkForce "${lib.getExe config.services.prowlarr.package} -nobrowser -data=${dataDir}";
    ReadWritePaths = [ dataDir ];
  };

  systemd.tmpfiles.rules = [
    "d '${dataDir}' 0700 ${user} root - -"
  ];
}
