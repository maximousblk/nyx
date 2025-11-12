{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.chaotic.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index

    ./hardware
    ./nixos
    ./user.nix
  ];

  system.stateVersion = "25.05"; # I do not read comments
  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;

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

  programs.partition-manager.enable = true;
  programs.ssh = {
    startAgent = false;
    enableAskPassword = true;
  };

  environment.variables = {
    SSH_ASKPASS_REQUIRE = "prefer";
    ZED_WINDOW_DECORATIONS = "server";
  };

  programs.firefox.enable = true;

  networking.firewall = {
    enable = false;
    trustedInterfaces = [ "tailscale0" ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.zed-mono
  ];

  powerManagement.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

}
