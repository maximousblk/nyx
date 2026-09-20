{
  inputs,
  modulesPath,
  pkgx,
  pkgs,
  ...
}:
{
  boot.zfs = {
    forceImportRoot = false;
  };

  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    ./hardware.nix
    ./incus.nix
    ./network.nix
  ];

  users.users = {
    root.openssh.authorizedKeys.keyFiles = [ inputs.ssh-keys-maximousblk ];
    maximousblk = {
      isNormalUser = true;
      extraGroups = [
        "incus-admin"
        "wheel"
      ];
      hashedPassword = "$y$j9T$SoBGPt7DQ4HZUvUl/EfPg/$zQlWUcr34xNtVNVNMhdmwB02tfCBkClvgZChP/qc7..";
      openssh.authorizedKeys.keyFiles = [ inputs.ssh-keys-maximousblk ];
    };
  };

  security.sudo.wheelNeedsPassword = false;
  nix.settings.max-jobs = 1;
  environment = {
    systemPackages = [ pkgs.incus ];
    variables.INCUS_PROJECT = "erebus";
  };
  documentation.nixos.enable = false;
  system.stateVersion = "26.05";
}
