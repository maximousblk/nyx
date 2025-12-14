{ pkgs, ... }:
{
  imports = [
    ./disko.nix
  ];

  system.stateVersion = "25.05";

  networking.hostName = "pyre";

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hardware configuration
  facter.reportPath = ./facter.json;

  # Impermanence
  fileSystems."/persistent".neededForBoot = true;

  environment.persistence."/persistent" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
    users.maximousblk = {
      directories = [
        ".ssh"
        "workspace"
      ];
    };
  };

  # Users
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDCoRsI0EOags5LP+Iy8/qfwKBzVzG+rlb1nszrJsaew"
  ];

  users.users.maximousblk = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$y$j9T$SoBGPt7DQ4HZUvUl/EfPg/$zQlWUcr34xNtVNVNMhdmwB02tfCBkClvgZChP/qc7..";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDCoRsI0EOags5LP+Iy8/qfwKBzVzG+rlb1nszrJsaew"
    ];
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "prohibit-password";
  };

  security.sudo.wheelNeedsPassword = false;
}
