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

  sops = {
    secrets =
      let
        sopsFile = ../../../secrets/headscale.yaml;
      in
      {
        "headscale/scaleway_access_key" = {
          inherit sopsFile;
          key = "scaleway_access_key";
        };
        "headscale/scaleway_secret_key" = {
          inherit sopsFile;
          key = "scaleway_secret_key";
        };
      };

    templates."litestream_env" = {
      content = ''
        HEADSCALE_ACCESS_KEY=${sops.placeholder."headscale/scaleway_access_key"}
        HEADSCALE_SECRET_KEY=${sops.placeholder."headscale/scaleway_secret_key"}
      '';
      restartUnits = [ "litestream.service" ];
    };
  };

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

    litestream = {
      environmentFile = sops.templates."litestream_env".path;
      settings.dbs = [
        {
          inherit (cfg_headscale.settings.database.sqlite) path;
          replica = {
            type = "s3";
            bucket = buckets.headscale;
            inherit endpoint region;
            storage-class = "ONEZONE_IA";
            # Enable automatic recovery from replication errors.
            # See https://litestream.io/reference/config/#auto-recover.
            auto-recover = true;
            access-key-id = "\${HEADSCALE_ACCESS_KEY}";
            secret-access-key = "\${HEADSCALE_SECRET_KEY}";
          };
        }
      ];
    };
  };

  systemd.services = {
    # Restore as headscale, since `litestream restore` leaves the files owned by whoever runs it.
    headscale = {
      serviceConfig.LoadCredential = [ "litestream_env:${sops.templates."litestream_env".path}" ];
      preStart = ''
        set -a; source "$CREDENTIALS_DIRECTORY/litestream_env"; set +a
        ${lib.escapeShellArgs [
          (lib.getExe cfg_litestream.package)
          "restore"
          "-if-db-not-exists"
          "-if-replica-exists"
          cfg_headscale.settings.database.sqlite.path
        ]}
      '';
    };
    # Litestream runs as root, so one instance can reach every app's database.
    # Upstream's own unit runs as root too: https://github.com/benbjohnson/litestream/blob/main/etc/litestream.service
    litestream = {
      after = [ "headscale.service" ];
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
        ReadWritePaths = [ (dirOf cfg_headscale.settings.database.sqlite.path) ];
        # Makes the host key that sops decrypts with, and the other services' secrets and credentials,
        # inaccessible. `services.litestream.environmentFile` still works: systemd reads it before hiding anything.
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
