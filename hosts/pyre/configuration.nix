{ ... }:
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
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDCoRsI0EOags5LP+Iy8/qfwKBzVzG+rlb1nszrJsaew" ];
    };

    maximousblk = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      hashedPassword = "$y$j9T$SoBGPt7DQ4HZUvUl/EfPg/$zQlWUcr34xNtVNVNMhdmwB02tfCBkClvgZChP/qc7..";
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDCoRsI0EOags5LP+Iy8/qfwKBzVzG+rlb1nszrJsaew" ];
    };
  };

  systemd.tmpfiles.rules = [ "d /mnt/data 0755 root root -" ];

  security.sudo.wheelNeedsPassword = false;
}
