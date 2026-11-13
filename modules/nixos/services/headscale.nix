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
  inherit (flakeCfg) fqdns headnetDomain homeserver;
  inherit (targetCfg) ports username;
  cfg = config.services.headscale;
  inherit (config.sops) secrets;
  homeserverIp = targetCfgs.nixos.${homeserver}.addresses.tailnet;
  owner = "${username}@";
  ownerTag = "tag:${username}";
in
{
  sops.secrets."headscale_noise_private_key" = {
    owner = cfg.user;
    restartUnits = [ "headscale.service" ];
    sopsFile = ../../../secrets/headscale.yaml;
  };

  services.headscale = {
    enable = true;
    port = ports.headscale;
    settings = {
      server_url = "https://${fqdns.headscale}";
      derp.server = {
        enabled = true;
        stun_listen_addr = ":${toString ports.headscale-stun}";
        verify_clients = true;
      };
      dns = {
        base_domain = headnetDomain;
        nameservers.global = [ homeserverIp ];
      };
      node.expiry = "180d";
      noise.private_key_path = secrets."headscale_noise_private_key".path;
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

  networking.firewall.allowedUDPPorts = [ ports.headscale-stun ];

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
