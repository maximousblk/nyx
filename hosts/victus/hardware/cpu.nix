{ pkgs, ... }:
{
  hardware.cpu.intel.updateMicrocode = true;

  boot.initrd.kernelModules = [ "i915" ];

  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    intel-compute-runtime
    onevpl-intel-gpu
  ];

  hardware.graphics.extraPackages32 = with pkgs.driversi686Linux; [
    intel-media-driver
    intel-compute-runtime
  ];
}
