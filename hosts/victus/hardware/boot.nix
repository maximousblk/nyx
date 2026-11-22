{ pkgs, ... }: {

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  boot.extraModulePackages = [ ];

  # Kernel
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v4;

  boot.kernelParams = [
    "intel_idle.max_cstate=4"
    "video=eDP-1:d" # Disable the faulty internal panel for both the console and Niri.
  ];

  boot.kernelModules = [ "ntfs" ];
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
