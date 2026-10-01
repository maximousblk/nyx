{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./incus.nix
    ./network.nix
    ./orca.nix
  ];

  environment.defaultPackages = lib.mkForce [ ];
  environment.systemPackages = [
    pkgs.bashInteractive
    pkgs.uutils-coreutils
  ];

  security.sudo.wheelNeedsPassword = false;

  users = {
    mutableUsers = false;
    users.root = {
      hashedPassword = "!";
      shell = pkgs.bashInteractive;
      openssh.authorizedKeys.keyFiles = [ inputs.ssh-keys-maximousblk ];
    };

  };

  documentation.enable = false;
  documentation.nixos.enable = false;
  programs.command-not-found.enable = false;
  system.stateVersion = "26.05";
}
