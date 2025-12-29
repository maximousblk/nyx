{ inputs, ... }:
{
  imports = [
    ./disko.nix
    ./network.nix
    ./services
    ./containers
  ];

  system.stateVersion = "25.05";

  networking.hostName = "pyre";

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hardware configuration
  facter.reportPath = ./facter.json;

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

  systemd.tmpfiles.rules = [ "d /mnt/data 0755 root root -" ];

  security.sudo.wheelNeedsPassword = false;

  topology.self = {
    name = "pyre";
    hardware.info = "Intel N150, 16GB RAM, Skullsaints Agni";
    interfaces.enp2s0.network = "nyx";
    interfaces.tailscale0 = {
      network = "tailscale";
      type = "tun";
      virtual = true;
      addresses = [ "100.100.2.2" ];
    };
  };
}
