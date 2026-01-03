{ pkgs, lib, ... }:
{
  services.fstrim.enable = lib.mkDefault true;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vpl-gpu-rt
    ];
  };
}
