{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-Verbatim_Vi3000_493744058892945";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            name = "ESP";
            start = "1M";
            end = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            end = "-8G";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
              };
            };
          };
          swap = {
            size = "100%";
            content = {
              type = "swap";
              discardPolicy = "both";
            };
          };
        };
      };
    };

    disk.parity = {
      type = "disk";
      device = "/dev/disk/by-id/ata-ST1000DM003-1ER162_Z4YDAVPY";
      content = {
        type = "gpt";
        partitions = {
          parity = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "xfs";
              mountpoint = "/mnt/parity1";
            };
          };
        };
      };
    };

    disk.data1 = {
      type = "disk";
      device = "/dev/disk/by-id/ata-ST1000LM049-2GH172_WN94J68M";
      content = {
        type = "gpt";
        partitions = {
          data = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "xfs";
              mountpoint = "/mnt/disk1";
            };
          };
        };
      };
    };

    disk.data2 = {
      type = "disk";
      device = "/dev/disk/by-id/ata-TOSHIBA_MQ01ABD050V_X3LPS10MS";
      content = {
        type = "gpt";
        partitions = {
          data = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "xfs";
              mountpoint = "/mnt/disk2";
            };
          };
        };
      };
    };
  };
}
