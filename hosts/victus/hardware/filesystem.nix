{ ... }:
{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/c8828a35-ae8a-4c95-9752-2725aa9b80ad";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A170-1DA4";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/50176178-3039-42e1-89c6-8a50523e2a1a"; } ];
}
