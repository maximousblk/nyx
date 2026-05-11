{ inputs, ... }:
{
  imports = [
    ./disko.nix
    ./network.nix
    ./services
  ];

  system.stateVersion = "25.05";

  facter.reportPath = ./facter.json;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    "console=tty1"
    "console=ttyAMA0,115200"
  ];
  boot.tmp.cleanOnBoot = true;

  documentation.nixos.enable = false;

  users.users = {
    root.openssh.authorizedKeys.keyFiles = [ inputs.ssh-keys-maximousblk ];

    maximousblk = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      hashedPassword = "$y$j9T$SoBGPt7DQ4HZUvUl/EfPg/$zQlWUcr34xNtVNVNMhdmwB02tfCBkClvgZChP/qc7..";
      openssh.authorizedKeys.keyFiles = [ inputs.ssh-keys-maximousblk ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  topology.self = {
    name = "scry";
    hardware.info = "OCI Ampere A1, 4 OCPU, 24GB RAM";
    deviceIcon = "devices.cloud-server";
    interfaces.enp0s6 = {
      type = "ethernet";
      addresses = [ "DHCP" ];
      network = "celest";
      virtual = true;
    };
    interfaces.tailscale0 = {
      network = "tailscale";
      type = "tun";
      virtual = true;
      addresses = [ "100.100.2.4" ];
    };
  };
}
