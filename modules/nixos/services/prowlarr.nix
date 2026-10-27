{
  targetCfg,

  config,
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
    # Keep the default `dataDir` so the upstream tmpfiles and bind-mount
    # rules stay off; `ExecStart` below points prowlarr at our path.
  };

  # HACK: A static user instead of `DynamicUser`, as nixarr does. With
  # `DynamicUser` and a custom `dataDir`, each activation resets `dataDir`
  # to `root:root 0700` and prowlarr can no longer read it.
  users.users.${user} = {
    isSystemUser = true;
    inherit group;
  };
  users.groups.${group} = { };

  systemd.services.prowlarr.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = lib.mkForce user;
    Group = lib.mkForce group;
    # State lives in `dataDir`, not `/var/lib/prowlarr`.
    StateDirectory = lib.mkForce "";
    ExecStart = lib.mkForce "${lib.getExe config.services.prowlarr.package} -nobrowser -data=${dataDir}";
    ReadWritePaths = [ dataDir ];
  };

  systemd.tmpfiles.rules = [
    "d '${dataDir}' 0700 ${user} root - -"
  ];
}
