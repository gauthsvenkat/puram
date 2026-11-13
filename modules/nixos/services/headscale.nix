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
  inherit (flakeCfg) dnsServer fqdns headnetDomain;
  inherit (targetCfg) headnetPrefixes ports username;
  cfg = config.services.headscale;
  inherit (config.sops) secrets;
  dnsServerIp = targetCfgs.nixos.${dnsServer}.addresses.headnet;
  owner = "${username}@";
  ownerTag = "tag:${username}";
in
{
  sops.secrets."headscale_noise_private_key" = {
    owner = cfg.user;
    restartUnits = [ "headscale.service" ];
    sopsFile = ../../../secrets/headscale.yaml;
  };

  services = {
    headscale = {
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
          nameservers.global = [ dnsServerIp ];
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
                  dst = [ controlTag ];
                  ip = [
                    "tcp:53"
                    "udp:53"
                  ];
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
        prefixes = headnetPrefixes;
        trusted_proxies = [ "127.0.0.1/32" ];
      };
    };

    # Headscale needs DNS to start (for the DERP map),
    # so its host resolves on its own, not through the headnet.
    tailscale.extraSetFlags = [ "--accept-dns=false" ];
  };

  networking = {
    firewall.allowedUDPPorts = [ ports.headscale-stun ];
    # Ignore the resolver that DHCP hands out, so only `nameservers` end up in `resolv.conf`.
    networkmanager.dns = "none";
    # Resolvers that do not depend on the headnet, for the same reason.
    nameservers = [
      "1.1.1.1"
      "9.9.9.9"
      "2606:4700:4700::1111"
      "2620:fe::fe"
    ];
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
