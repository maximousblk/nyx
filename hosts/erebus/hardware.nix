{ pkgs, ... }: {
  boot = {
    kernelPackages = pkgs.linuxPackages;
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    kernelParams = [ "console=tty1" ];
  };

  hardware = {
    deviceTree.filter = "bcm2711-rpi-4-b.dtb";
    enableRedistributableFirmware = true;
    firmware = [ pkgs.raspberrypiWirelessFirmware ];
  };

  swapDevices = [ ];
}
