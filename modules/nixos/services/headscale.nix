{
  flakeCfg,
  targetCfg,

  targetCfgs,

  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (flakeCfg) domain headnetDomain homeserver;
  inherit (targetCfg) username;
  inherit (targetCfgs.nixos.${homeserver}) tailnetIp;
  cfg = config.services.headscale;
  owner = "${username}@";
  ownerTag = "tag:${username}";
in
{
  services.headscale = {
    enable = true;
    settings = {
      server_url = "https://headscale.${domain}";
      dns = {
        base_domain = headnetDomain;
        nameservers.global = [ tailnetIp ];
      };
      node.expiry = "180d";
      policy.path =
        let
          controlTag = "tag:control";
          serverTag = "tag:server";
        in
        pkgs.writeText "policy.json" (
          lib.toJSON {
            grants = [
              {
                src = [
                  owner
                  ownerTag
                ];
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
                  "tcp:53"
                  "udp:53"
                  "tcp:80"
                  "tcp:443"
                ];
              }
            ];
            tagOwners = {
              ${controlTag} = [ owner ];
              ${ownerTag} = [ owner ];
              ${serverTag} = [ owner ];
            };
          }
        );
    };
  };

  systemd.services."headscale-user" = {
    after = [ "headscale.service" ];
    requires = [ "headscale.service" ];
    path = [ cfg.package ];
    script = ''
      until headscale users list --name ${username} -o json | grep -q '"name"' \
        || headscale users create ${username}; do sleep 1; done
    '';
    serviceConfig = {
      Group = cfg.group;
      TimeoutStartSec = "1min";
      Type = "oneshot";
      User = cfg.user;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
