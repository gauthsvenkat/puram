{
  flakeCfg,
  targetCfg,

  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (flakeCfg) domain;
  inherit (targetCfg) username;
  cfg = config.services.headscale;
  owner = "${username}@";
  controlTag = "tag:control";
  serverTag = "tag:server";
in
{
  services.headscale = {
    enable = true;
    settings = {
      server_url = "https://headscale.${domain}";
      node.expiry = "180d";
      dns = {
        base_domain = "headnet.${domain}";
        override_local_dns = false;
      };
      policy.path = pkgs.writeText "policy.json" (
        lib.toJSON {
          grants = [
            {
              src = [ owner ];
              dst = [ "*" ];
              ip = [ "*" ];
            }
            {
              src = [ "autogroup:member" ];
              dst = [ "autogroup:self" ];
              ip = [ "*" ];
            }
            {
              src = [ "autogroup:member" ];
              dst = [ serverTag ];
              ip = [
                "tcp:80"
                "tcp:443"
              ];
            }
          ];
          tagOwners = {
            ${controlTag} = [ owner ];
            ${serverTag} = [ owner ];
          };
        }
      );
    };
  };

  systemd.services."headscale-user" = {
    after = [ "headscale.service" ];
    requires = [ "headscale.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ cfg.package ];
    serviceConfig = {
      Type = "oneshot";
      User = cfg.user;
      Group = cfg.group;
      TimeoutStartSec = "1min";
    };
    script = ''
      until headscale users list --name ${username} -o json | grep -q '"name"' \
        || headscale users create ${username}; do sleep 1; done
    '';
  };
}
