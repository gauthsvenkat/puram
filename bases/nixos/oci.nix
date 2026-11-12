{
  imports = [ ./server.nix ];

  # From https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/virtualisation/oci-common.nix,
  # not imported directly because its `fileSystems.*` clash with disko's.
  boot = {
    kernelParams = [
      "nvme.shutdown_timeout=10"
      "nvme_core.shutdown_timeout=10"
      "libiscsi.debug_libiscsi_eh=1"
      "crash_kexec_post_notifiers"
      "console=tty1"
      "console=ttyAMA0,115200"
    ];
    loader.efi.canTouchEfiVariables = false;
  };

  # Oracle's NTP service on the link-local metadata address; https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/configuringntpservice.htm
  networking.timeServers = [ "169.254.169.254" ];
}
