{ inputs, ... }:
{
  imports = [
    ./disko.nix
    ./network.nix
    ./secrets.nix
    ./services
  ];

  system.stateVersion = "25.05";

  networking.hostName = "cairn";

  # Boot
  boot.loader.limine.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [
    "btrfs"
    "xfs"
  ];

  # Hardware configuration
  facter.reportPath = ./facter.json;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  # Users
  users.users = {
    root = {
      openssh.authorizedKeys.keyFiles = [ inputs.ssh-keys-maximousblk ];
    };

    maximousblk = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      hashedPassword = "$y$j9T$SoBGPt7DQ4HZUvUl/EfPg/$zQlWUcr34xNtVNVNMhdmwB02tfCBkClvgZChP/qc7..";
      openssh.authorizedKeys.keyFiles = [ inputs.ssh-keys-maximousblk ];
    };
  };

  systemd.tmpfiles.settings = {
    "10-mnt-dirs" = {
      "/mnt/data".d = {
        mode = "0755";
        user = "root";
        group = "root";
      };
      "/mnt/disk1".d = {
        mode = "0755";
        user = "root";
        group = "root";
      };
      "/mnt/disk2".d = {
        mode = "0755";
        user = "root";
        group = "root";
      };
      "/mnt/parity1".d = {
        mode = "0755";
        user = "root";
        group = "root";
      };
    };
  };

  services.fstrim.enable = true;
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  topology.self = {
    name = "cairn";
    hardware.info = "Intel Core i5-6600T, 16GB RAM, Gigabyte Z170M-D3H";
    deviceIcon = "devices.cloud-server";
    interfaces.enp0s31f6 = {
      type = "ethernet";
      network = "nyx";
      physicalConnections = [
        {
          node = "switch";
          interface = "lan3";
          renderer.reverse = true;
        }
      ];
    };
    interfaces.tailscale0 = {
      network = "tailscale";
      type = "tun";
      virtual = true;
      addresses = [ "100.100.2.3" ];
    };
  };
}
