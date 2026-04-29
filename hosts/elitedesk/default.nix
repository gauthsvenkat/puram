{
  hostCfg,
  pkgs,
  ...
}:
let
  inherit (hostCfg) username zpool;
in
{
  imports = [
    ../../bases/nixos/flavor/server.nix

    ../../modules/nixos/hardware/intel-transcoding.nix

    ../../modules/nixos/services/adguard-home.nix
    ../../modules/nixos/services/homarr.nix
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

    tailscale.enable = true;

    # Shared by every service that opts to use postgresql (paperless, immich, ...).
    postgresql.dataDir = hostCfg.paths.postgres;

    jellyfin = {
      hardwareAcceleration = {
        enable = true;
        type = "qsv";
        device = "/dev/dri/renderD128";
      };
      # NixOS owns encoding.xml; existing file from the cloned dataset is
      # backed up to encoding.xml.backup-<timestamp> on first boot.
      forceEncodingConfig = true;
      transcoding = {
        enableHardwareEncoding = true;
        # Codec list verified via vainfo on elitedesk's Skylake-era iGPU.
        # No VP9 / AV1 / HEVC Main10 support; HEVC encode is 8-bit Main only.
        hardwareDecodingCodecs = {
          h264 = true;
          hevc = true;
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
      device = "${hostCfg.paths.config}/adguard-home";
      fsType = "none";
      options = [ "bind" ];
      depends = [ "/${zpool}" ];
    };
    "/var/lib/private/stirling-pdf" = {
      device = "${hostCfg.paths.config}/stirling-pdf";
      fsType = "none";
      options = [ "bind" ];
      depends = [ "/${zpool}" ];
    };
  };

  home-manager.users.${username}.home.packages = [ pkgs.age ];
}
