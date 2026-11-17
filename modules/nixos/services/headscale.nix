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
  inherit (flakeCfg)
    dnsServer
    fqdns
    headnetDomain
    pocketId
    ;
  inherit (targetCfg) headnetPrefixes ports username;
  inherit (config.sops) secrets;
  cfg = config.services.headscale;
  dnsServerIp = targetCfgs.nixos.${dnsServer}.addresses.headnet;
  owner = "${username}@";
in
{
  sops.secrets =
    let
      owner = cfg.user;
      restartUnits = [ "headscale.service" ];
    in
    {
      "headscale/headscale_noise_private_key" = {
        sopsFile = ../../../secrets/headscale.yaml;
        key = "headscale_noise_private_key";
        inherit owner restartUnits;
      };
      "pocket-id/pocket_id_headscale_client_secret" = {
        sopsFile = ../../../secrets/pocket-id.yaml;
        key = "pocket_id_headscale_client_secret";
        inherit owner restartUnits;
      };
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
        noise.private_key_path = secrets."headscale/headscale_noise_private_key".path;
        oidc = {
          issuer = "https://${fqdns.pocket-id}";
          client_id = pocketId.clientIds.headscale;
          client_secret_path = secrets."pocket-id/pocket_id_headscale_client_secret".path;
          pkce.enabled = true;
        };
        policy.path =
          let
            controlTag = "tag:control";
            dnsTag = "tag:dns";
            serverTag = "tag:server";
          in
          pkgs.writeText "policy.json" (
            lib.toJSON {
              tagOwners = {
                ${controlTag} = [ owner ];
                ${dnsTag} = [ owner ];
                ${serverTag} = [ owner ];
              };
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
                  src = [ "*" ];
                  dst = [ dnsTag ];
                  ip = [
                    "tcp:53"
                    "udp:53"
                  ];
                }
                {
                  src = [ "autogroup:member" ];
                  dst = [ serverTag ];
                  ip = [ "tcp:443" ];
                }
              ];
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
