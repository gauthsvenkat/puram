{ ... }:
{
  imports = [
    ../../modules/nixos/hardware/intel-transcoding.nix
  ];

  services = {
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
  users.users =
    let
      extraGroups = [
        "render"
        "video"
      ];
    in
    {
      jellyfin = { inherit extraGroups; };
      immich = { inherit extraGroups; };
    };
}
