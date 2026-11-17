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
  cfg_pocket_id = config.services.pocket-id;
  headscaleDb = cfg_headscale.settings.database.sqlite.path;
  pocketIdDb = cfg_pocket_id.settings.DB_CONNECTION_STRING;
in
{
  imports = [
    ../../../bases/nixos/oci.nix

    ../../../modules/nixos/services/adguard-home.nix
    ../../../modules/nixos/services/caddy.nix
    ../../../modules/nixos/services/headplane.nix
    ../../../modules/nixos/services/headscale.nix
    ../../../modules/nixos/services/litestream.nix
    ../../../modules/nixos/services/oauth2-proxy.nix
    ../../../modules/nixos/services/pocket-id.nix
    ../../../modules/nixos/services/tailscale.nix

    ./disko-config.nix
    ./hardware-configuration.nix
  ];

  sops = {
    secrets =
      let
        headscaleFile = ../../../secrets/headscale.yaml;
        pocketIdFile = ../../../secrets/pocket-id.yaml;
      in
      {
        "headscale/scaleway_access_key" = {
          sopsFile = headscaleFile;
          key = "scaleway_access_key";
        };
        "headscale/scaleway_secret_key" = {
          sopsFile = headscaleFile;
          key = "scaleway_secret_key";
        };
        "pocket-id/scaleway_access_key" = {
          sopsFile = pocketIdFile;
          key = "scaleway_access_key";
        };
        "pocket-id/scaleway_secret_key" = {
          sopsFile = pocketIdFile;
          key = "scaleway_secret_key";
        };
      };

    templates = {
      "litestream_headscale_env" = {
        content = ''
          HEADSCALE_ACCESS_KEY=${sops.placeholder."headscale/scaleway_access_key"}
          HEADSCALE_SECRET_KEY=${sops.placeholder."headscale/scaleway_secret_key"}
        '';
        restartUnits = [ "litestream.service" ];
      };
      "litestream_pocket_id_env" = {
        content = ''
          POCKET_ID_ACCESS_KEY=${sops.placeholder."pocket-id/scaleway_access_key"}
          POCKET_ID_SECRET_KEY=${sops.placeholder."pocket-id/scaleway_secret_key"}
        '';
        restartUnits = [ "litestream.service" ];
      };
    };
  };

  services = {
    # Caddy terminates TLS, so AdGuard answers DoH over plain HTTP behind it.
    adguardhome.settings.http.doh.insecure_enabled = true;

    caddy.virtualHosts = {
      ${fqdns.auth}.extraConfig = ''
        @headnet remote_ip ${headnetPrefixes.v4} ${headnetPrefixes.v6}
        handle @headnet {
          reverse_proxy 127.0.0.1:${toString ports.oauth2-proxy}
        }
        respond 404
      '';
      ${fqdns.adguard}.extraConfig = ''
        @headnet remote_ip ${headnetPrefixes.v4} ${headnetPrefixes.v6}
        handle @headnet {
          forward_auth 127.0.0.1:${toString ports.oauth2-proxy} {
            uri /oauth2/auth?allowed_groups=admins
            @unauthorized status 401
            handle_response @unauthorized {
              redir * https://${fqdns.auth}/oauth2/start?rd={scheme}://{host}{uri}
            }
          }
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
      ${fqdns.pocket-id}.extraConfig = ''
        @headnet remote_ip ${headnetPrefixes.v4} ${headnetPrefixes.v6}
        handle @headnet {
          reverse_proxy 127.0.0.1:${toString ports.pocket-id}
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

    litestream.settings.dbs =
      let
        mkDb = path: bucket: envPrefix: {
          inherit path;
          replica = {
            type = "s3";
            inherit bucket endpoint region;
            storage-class = "ONEZONE_IA";
            # Enable automatic recovery from replication errors.
            # See https://litestream.io/reference/config/#auto-recover.
            auto-recover = true;
            access-key-id = "\${${envPrefix}_ACCESS_KEY}";
            secret-access-key = "\${${envPrefix}_SECRET_KEY}";
          };
        };
      in
      [
        (mkDb headscaleDb buckets.headscale "HEADSCALE")
        (mkDb pocketIdDb buckets.pocket-id "POCKET_ID")
      ];
  };

  systemd.services =
    let
      restore = path: ''
        set -a; source "$CREDENTIALS_DIRECTORY/litestream_env"; set +a
        ${lib.escapeShellArgs [
          (lib.getExe cfg_litestream.package)
          "restore"
          "-if-db-not-exists"
          "-if-replica-exists"
          path
        ]}
      '';
    in
    {
      headscale = {
        serviceConfig.LoadCredential = [
          "litestream_env:${sops.templates."litestream_headscale_env".path}"
        ];
        preStart = restore headscaleDb;
      };
      pocket-id = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig.LoadCredential = [
          "litestream_env:${sops.templates."litestream_pocket_id_env".path}"
        ];
        preStart = restore pocketIdDb;
      };
      # Litestream runs as root, so one instance can reach every app's database.
      # Upstream's own unit runs as root too: https://github.com/benbjohnson/litestream/blob/main/etc/litestream.service
      litestream = {
        after = [
          "headscale.service"
          "pocket-id.service"
        ];
        serviceConfig = {
          User = lib.mkForce "root";
          Group = lib.mkForce "root";
          # Of root's powers, only
          # - `chown` (hand files back),
          # - `dac_override` (read and write the apps' files),
          # - `fowner` (set their modes).
          # Without the rest, it can't undo the restrictions below.
          # https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#CapabilityBoundingSet=
          CapabilityBoundingSet = [
            "CAP_CHOWN"
            "CAP_DAC_OVERRIDE"
            "CAP_FOWNER"
          ];
          # The whole filesystem is read-only to it, except the databases it replicates.
          # https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#ProtectSystem=
          ProtectSystem = "strict";
          ReadWritePaths = [
            (dirOf headscaleDb)
            cfg_pocket_id.dataDir
          ];
          EnvironmentFile = [
            sops.templates."litestream_headscale_env".path
            sops.templates."litestream_pocket_id_env".path
          ];
          # Makes the host key that sops decrypts with, and the other services' secrets and credentials,
          # inaccessible. Its `EnvironmentFile` still works: systemd reads it before hiding anything.
          # https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#EnvironmentFile=
          InaccessiblePaths = [
            "-/etc/ssh"
            "-/run/credentials"
            "-/run/secrets-for-users.d"
            "-/run/secrets.d"
          ];
        };
      };
    };
}
