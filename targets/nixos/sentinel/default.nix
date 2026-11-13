{
  flakeCfg,
  targetCfg,

  config,
  lib,
  ...
}:
let
  inherit (flakeCfg) fqdns;
  inherit (flakeCfg.backups) buckets endpoint region;
  inherit (targetCfg) headnetPrefixes ports;
  inherit (config) sops;
  cfg_headscale = config.services.headscale;
  cfg_litestream = config.services.litestream;
  headscaleUnit = config.systemd.services.headscale.serviceConfig;
in
{
  imports = [
    ../../../bases/nixos/oci.nix

    ../../../modules/nixos/services/adguard-home.nix
    ../../../modules/nixos/services/caddy.nix
    ../../../modules/nixos/services/headplane.nix
    ../../../modules/nixos/services/headscale.nix
    ../../../modules/nixos/services/litestream.nix
    ../../../modules/nixos/services/tailscale.nix

    ./disko-config.nix
    ./hardware-configuration.nix
  ];

  services = {
    # Caddy terminates TLS, so AdGuard answers DoH over plain HTTP behind it.
    adguardhome.settings.http.doh.insecure_enabled = true;

    caddy.virtualHosts = {
      ${fqdns.adguard}.extraConfig = ''
        @headnet remote_ip ${headnetPrefixes.v4} ${headnetPrefixes.v6}
        handle @headnet {
          reverse_proxy 127.0.0.1:${toString ports.adguard}
        }
        respond 404
      '';
      ${fqdns.dns}.extraConfig = ''
        handle /dns-query* {
          reverse_proxy 127.0.0.1:${toString ports.adguard}
        }
        respond 404
      '';
      ${fqdns.headscale}.extraConfig = ''
        @headscale {
          # Control
          path /ts2021 /key /machine/ping-response
          # Login
          path /register/* /auth/*
          # Relay
          path /derp /derp/probe /derp/latency-check /bootstrap-dns
          # Monitoring
          path /health
          # Setup guides
          path /apple /apple/* /windows
          # Static
          path / /favicon.ico /robots.txt
        }
        handle @headscale {
          reverse_proxy 127.0.0.1:${toString ports.headscale}
        }
        respond 404
      '';
      ${fqdns.headplane}.extraConfig = ''
        @headnet remote_ip ${headnetPrefixes.v4} ${headnetPrefixes.v6}
        handle @headnet {
          redir / /admin/
          reverse_proxy 127.0.0.1:${toString ports.headplane}
        }
        respond 404
      '';
    };

    litestream.settings.dbs = [
      {
        inherit (cfg_headscale.settings.database.sqlite) path;
        replica = {
          type = "s3";
          bucket = buckets.headscale;
          inherit endpoint region;
          storage-class = "ONEZONE_IA";
          auto-recover = true;
          access-key-id = "\${HEADSCALE_ACCESS_KEY}";
          secret-access-key = "\${HEADSCALE_SECRET_KEY}";
        };
      }
    ];
  };

  systemd.services = {
    headscale.after = [ "litestream.service" ];
    "headscale-restore" = {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      before = [
        "headscale.service"
        "litestream.service"
      ];
      requiredBy = [ "headscale.service" ];
      serviceConfig = {
        Type = "oneshot";
        # Stay active after success, so a headscale restart doesn't run the restore again.
        RemainAfterExit = true;
        User = cfg_headscale.user;
        Group = cfg_headscale.group;
        # Match headscale's unit, or systemd resets the folder's mode.
        inherit (headscaleUnit) StateDirectory StateDirectoryMode UMask;
        EnvironmentFile = sops.templates."litestream_env".path;
        ExecStart = lib.escapeShellArgs [
          (lib.getExe cfg_litestream.package)
          "restore"
          "-if-db-not-exists"
          "-if-replica-exists"
          cfg_headscale.settings.database.sqlite.path
        ];
      };
    };
    # Upstream runs Litestream as the `litestream` user, which can't write into headscale's state directory.
    litestream.serviceConfig = {
      User = lib.mkForce cfg_headscale.user;
      Group = lib.mkForce cfg_headscale.group;
    };
  };

  sops = {
    defaultSopsFile = ../../../secrets/dns.yaml;

    secrets =
      let
        sopsFile = ../../../secrets/headscale.yaml;
      in
      {
        "scaleway_access_key" = { inherit sopsFile; };
        "scaleway_secret_key" = { inherit sopsFile; };
      };

    templates."litestream_env".content = ''
      HEADSCALE_ACCESS_KEY=${sops.placeholder."scaleway_access_key"}
      HEADSCALE_SECRET_KEY=${sops.placeholder."scaleway_secret_key"}
    '';
  };
}
