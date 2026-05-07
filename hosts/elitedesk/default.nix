{
  hostCfg,
  ...
}:
let
  inherit (hostCfg)
    domain
    hostname
    paths
    zpool
    ;
  inherit (hostCfg.ports)
    adguard
    caddy
    immich
    jellyfin
    paperless
    ;
  loopback = p: "http://127.0.0.1:${toString p}";
in
{
  imports = [
    ../../bases/nixos/flavor/server.nix

    ../../modules/common/tailscale.nix

    ../../modules/nixos/hardware/intel-transcoding.nix

    ../../modules/nixos/services/adguard-home.nix
    ../../modules/nixos/services/caddy.nix
    ../../modules/nixos/services/homepage.nix
    ../../modules/nixos/services/immich.nix
    ../../modules/nixos/services/jellyfin.nix
    ../../modules/nixos/services/paperless-ngx.nix
    ../../modules/nixos/services/sanoid.nix
    ../../modules/nixos/services/speedtest-tracker.nix
    ../../modules/nixos/services/stirling-pdf.nix
    ../../modules/nixos/services/zfs.nix

    ./disko-config.nix
    ./hardware-configuration.nix
  ];

  boot.zfs.extraPools = [ zpool ];

  services = {
    sanoid.datasets = {
      "${zpool}" = {
        recursive = true;
        process_children_only = true;
        use_template = [ "default" ];
      };
      "${zpool}/cache".autosnap = false;
    };

    # Shared by every service that opts to use postgresql (paperless, immich, ...).
    postgresql.dataDir = paths.postgres;

    jellyfin = {
      hardwareAcceleration = {
        enable = true;
        # VAAPI, not QSV: Skylake (Gen 9, HD 530) is past the support window
        # for both oneVPL and the legacy Intel Media SDK that QSV depends on.
        # Without this, HLS transcodes fail in the ffmpeg device-init step
        # ("Error creating a MFX session") and the Jellyfin client reports
        # "playback failed due to a fatal player error".
        # https://jellyfin.org/docs/general/post-install/transcoding/hardware-acceleration/intel
        type = "vaapi";
        device = "/dev/dri/renderD128";
      };
      # NixOS owns encoding.xml; existing file from the cloned dataset is
      # backed up to encoding.xml.backup-<timestamp> on first boot.
      forceEncodingConfig = true;
      transcoding = {
        enableHardwareEncoding = true;
        # Codec list verified via vainfo on elitedesk's Skylake-era iGPU.
        # No VP9 / AV1 / HEVC Main10 support; HEVC encode is 8-bit Main only.
        # HEVC decode is intentionally disabled: the GPU can do HEVC Main
        # (8-bit) but not Main10, and the nixpkgs jellyfin module does not
        # expose `EnableDecodingColorDepth10Hevc`, so we can't selectively
        # gate Main10 — leaving HEVC HW decode on causes ffmpeg to fail
        # ("No support for codec hevc profile 2") on any 10-bit HEVC source
        # instead of falling back to software decode. SW decode of 1080p
        # HEVC is comfortable on this CPU; HW H264 encoding still applies.
        hardwareDecodingCodecs = {
          h264 = true;
          mpeg2 = true;
          vc1 = true;
          vp8 = true;
        };
        hardwareEncodingCodecs.hevc = true;
      };
    };

    immich.accelerationDevices = [ "/dev/dri/renderD128" ];
  };

  # Neither the jellyfin nor immich modules add their service user to the
  # render/video groups; DeviceAllow grants cgroup-level access but POSIX
  # permissions on /dev/dri/renderD128 (mode 0660 root:render) still gate it.
  users.users = {
    jellyfin.extraGroups = [
      "render"
      "video"
    ];
    immich.extraGroups = [
      "render"
      "video"
    ];
  };

  # Bind-mount native services' state onto the ZFS pool so app data is
  # snapshot-managed alongside everything else.
  #
  # AdGuard Home and Stirling PDF run with `DynamicUser=true`. Per
  # systemd.exec(5), DynamicUser redirects `StateDirectory=` to
  # `/var/lib/private/<name>` (a root-only parent that guards against UID
  # recycling), and leaves `/var/lib/<name>` as a symlink for transparency.
  # We bind the private path so DynamicUser keeps working unchanged. If
  # systemd ever changes this internal layout, these mounts need revisiting.
  # Ref: https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#StateDirectory=
  fileSystems = {
    "/var/lib/private/AdGuardHome" = {
      device = "${paths.config}/adguard-home";
      fsType = "none";
      options = [ "bind" ];
      depends = [ "/${zpool}" ];
    };
    "/var/lib/private/stirling-pdf" = {
      device = "${paths.config}/stirling-pdf";
      fsType = "none";
      options = [ "bind" ];
      depends = [ "/${zpool}" ];
    };
  };

  services.homepage-dashboard = {
    settings = {
      title = hostname;
      headerStyle = "clean";
      theme = "dark";
      color = "slate";
      layout = [
        {
          "Infra" = {
            style = "row";
            columns = 2;
            useEqualHeights = true;
          };
        }
        {
          "Media" = {
            style = "row";
            columns = 3;
            useEqualHeights = true;
          };
        }
        {
          "Utilities" = {
            style = "row";
            columns = 3;
            useEqualHeights = true;
          };
        }
      ];
    };

    widgets = [
      {
        greeting = {
          text_size = "xl";
          text = hostname;
        };
      }
      {
        resources = {
          cpu = true;
          memory = true;
          disk = "/${zpool}";
        };
      }
      {
        datetime = {
          text_size = "xl";
          format = {
            timeStyle = "short";
            dateStyle = "long";
          };
        };
      }
      {
        search = {
          provider = "duckduckgo";
          target = "_blank";
        };
      }
      {
        openmeteo = {
          # Delft, The Netherlands
          latitude = "52.0116";
          longitude = "4.3571";
          units = "metric";
          cache = 5;
        };
      }
    ];

    services = [
      {
        "Infra" = [
          {
            "Caddy" = {
              icon = "caddy.svg";
              href = "https://${domain}";
              widget = {
                type = "caddy";
                url = loopback caddy.admin_port;
              };
            };
          }
          {
            "Tailscale" = {
              icon = "tailscale.svg";
              href = "https://login.tailscale.com/admin/machines";
            };
          }
        ];
      }
      {
        "Media" = [
          {
            "Jellyfin" = {
              icon = "jellyfin.svg";
              href = "https://jellyfin.${domain}";
              widget = {
                type = "jellyfin";
                url = loopback jellyfin.port;
                key = "{{HOMEPAGE_VAR_JELLYFIN_KEY}}";
                enableBlocks = true;
                enableMediaControl = false;
                version = 2;
              };
            };
          }
          {
            "Immich" = {
              icon = "immich.svg";
              href = "https://immich.${domain}";
              widget = {
                type = "immich";
                url = loopback immich.port;
                key = "{{HOMEPAGE_VAR_IMMICH_KEY}}";
                version = 2;
              };
            };
          }
          {
            "Paperless" = {
              icon = "paperless.svg";
              href = "https://paperless.${domain}";
              widget = {
                type = "paperlessngx";
                url = loopback paperless.port;
                key = "{{HOMEPAGE_VAR_PAPERLESS_KEY}}";
              };
            };
          }
        ];
      }
      {
        "Utilities" = [
          {
            "AdGuard Home" = {
              icon = "adguard-home.svg";
              href = "https://adguard.${domain}";
              widget = {
                type = "adguard";
                url = loopback adguard.web_port;
                username = "{{HOMEPAGE_VAR_ADGUARD_USER}}";
                password = "{{HOMEPAGE_VAR_ADGUARD_PASS}}";
              };
            };
          }
          {
            "Stirling PDF" = {
              icon = "stirling-pdf.svg";
              href = "https://stirling.${domain}";
            };
          }
          {
            "Speedtest" = {
              icon = "sh-speedtest-tracker.svg";
              href = "https://speedtest.${domain}";
              widget = {
                type = "speedtest";
                url = "https://speedtest.${domain}";
              };
            };
          }
        ];
      }
    ];
  };
}
