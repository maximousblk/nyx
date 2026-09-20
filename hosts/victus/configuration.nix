{
  pkgs,
  pkgx,
  lib,
  config,
  inputs,
  ...
}:
let
  paseoUser = config.services.paseo.user;
  paseoUserHome = config.users.users.${paseoUser}.home;
  paseoHomeProfile = config.home-manager.users.${paseoUser}.home.profileDirectory;
in
{
  imports = [
    inputs.paseo.nixosModules.default
    ./hardware
    ./nixos
    ./user.nix
  ];

  system.stateVersion = "25.05"; # I do not read comments

  networking.hostName = "victus"; # Define your hostname.

  # Enable networking
  networking.useDHCP = false;
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ALL = "en_GB.UTF-8";
  };

  programs.dconf.enable = true;

  environment.etc."udisks2/mount_options.conf".text = lib.generators.toINI { } {
    defaults = {
      ntfs_drivers = "ntfs";
    };
  };

  security.rtkit.enable = true;
  security.sudo.wheelNeedsPassword = false;

  programs.ssh = {
    startAgent = false;
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  networking.firewall = {
    enable = false;
    trustedInterfaces = [ "tailscale0" ];
  };

  services.paseo = {
    enable = true;
    user = "maximousblk";
    group = "users";
    listenAddress = "0.0.0.0";
    hostnames = true;
    relay.enable = false;
  };

  topology.self.services.paseo = {
    name = "Paseo";
    info = "Coding agent orchestration";
    icon = pkgx.topology-icons.paseo;
  };

  # Paseo's Home Manager PATH fix leaves NixOS wrappers after system binaries:
  # https://github.com/getpaseo/paseo/pull/1040
  systemd.services.paseo.environment.PATH = lib.mkOverride 40 (
    lib.concatStringsSep ":" [
      config.security.wrapperDir
      "${paseoUserHome}/.nix-profile/bin"
      "${paseoUserHome}/.local/state/nix/profile/bin"
      "${paseoHomeProfile}/bin"
      "${config.system.path}/bin"
    ]
  );

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.zed-mono
    ioskeley-mono.normal-NF
    ioskeley-mono.normal-term-NF
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  topology.self = {
    name = "victus";
    hardware.info = "Intel Core i7 12650H, 16GB RAM, HP Victus 15";
    deviceIcon = "devices.laptop";
    interfaces.wlp0s20f3 = {
      network = "nyx";
      addresses = lib.mkForce [ "DHCP" ];
      physicalConnections = [
        {
          node = "ap";
          interface = "wifi";
        }
      ];
    };
    interfaces.tailscale0 = {
      network = "tailscale";
      type = "tun";
      virtual = true;
      addresses = [ "100.100.1.1" ];
    };
  };

}
