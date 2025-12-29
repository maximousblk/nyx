{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
    inputs.sops-nix.nixosModules.sops

    ./hardware
    ./nixos
    ./user.nix
  ];

  system.stateVersion = "25.05"; # I do not read comments

  networking.hostName = "victus"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ALL = "en_GB.UTF-8";
  };

  programs.dconf.enable = true;

  security.rtkit.enable = true;
  security.sudo.wheelNeedsPassword = false;

  programs.nix-index-database.comma.enable = true;

  programs.ssh = {
    startAgent = false;
  };

  environment.variables = {
    ZED_WINDOW_DECORATIONS = "server";
  };

  programs.firefox.enable = true;

  networking.firewall = {
    enable = false;
    trustedInterfaces = [ "tailscale0" ];
  };

  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.zed-mono
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  topology.self = {
    name = "victus";
    hardware.info = "Intel i7 12th Gen, 16GB RAM, HP Victus 15";
    deviceIcon = "devices.laptop";
    interfaces.wlp0s20f3 = {
      network = "nyx";
      addresses = lib.mkForce [ "DHCP" ];
    };
    interfaces.tailscale0 = {
      network = "tailscale";
      type = "tun";
      virtual = true;
      addresses = [ "100.100.1.1" ];
    };
  };

}
