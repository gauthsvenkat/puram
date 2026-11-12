{
  targetCfg,

  config,
  lib,
  ...
}:
let
  inherit (targetCfg) paths;
  inherit (targetCfg.ports.prowlarr) port;
  cfg = config.services.prowlarr;
  dataDir = "${paths.config}/prowlarr";
  group = "prowlarr";
  user = "prowlarr";
in
{
  services.prowlarr = {
    enable = true;
    settings.server.port = port;
    # Keep the default `dataDir` so the upstream tmpfiles and bind-mount
    # rules stay off; `ExecStart` below points prowlarr at our path.
  };

  users = {
    # HACK: A static user instead of `DynamicUser`, as nixarr does. With
    # `DynamicUser` and a custom `dataDir`, each activation resets `dataDir`
    # to `root:root 0700` and prowlarr can no longer read it.
    groups.${group} = { };
    users.${user} = {
      inherit group;
      isSystemUser = true;
    };
  };

  systemd = {
    tmpfiles.rules = [
      "d '${dataDir}' 0700 ${user} root - -"
    ];

    services.prowlarr.serviceConfig = {
      DynamicUser = lib.mkForce false;
      ExecStart = lib.mkForce "${lib.getExe cfg.package} -nobrowser -data=${dataDir}";
      Group = lib.mkForce group;
      ReadWritePaths = [ dataDir ];
      # State lives in `dataDir`, not `/var/lib/prowlarr`.
      StateDirectory = lib.mkForce "";
      User = lib.mkForce user;
    };
  };
}
