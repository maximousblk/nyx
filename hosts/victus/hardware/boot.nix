{ pkgs, ... }:
{

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  boot.extraModulePackages = [ ];

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_cachyos-lto; # .cachyOverride { mArch = "GENERIC_V4"; }
  services.scx.enable = true;

  boot.kernelParams = [
    "intel_idle.max_cstate=4"
  ];

  boot.kernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  boot.initrd.availableKernelModules = [
    "nvme"
    "rtsx_pci_sdmmc"
    "sd_mod"
    "usb_storage"
    "usbhid"
    "xhci_pci"
  ];

}
