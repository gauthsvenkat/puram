{ pkgs, ... }:
{
  boot.kernelParams = [ "i915.enable_guc=2" ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver
    ];
  };
}
