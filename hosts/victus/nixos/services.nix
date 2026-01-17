{ pkgs, ... }:
{

  services.blueman.enable = true;
  services.openssh.enable = true;
  services.printing.enable = false;
  services.udisks2.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.upower.enable = true;
  services.fstrim.enable = true;
  services.hdapsd.enable = false;

  services.below = {
    enable = true;
    retention.size = 8 * 1000 * 1000 * 1000;
    compression.enable = true;
    collect.ioStats = true;
    collect.exitStats = true;
    collect.diskStats = true;
  };

  services.scx = {
    scheduler = "scx_bpfland";
    enable = true;
    package = pkgs.scx.full;
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    openFirewall = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };
  };

  services.sunshine = {
    enable = true;
    autoStart = false;
    capSysAdmin = true;
    openFirewall = true;

    package = pkgs.sunshine.override { cudaSupport = false; };
  };
  systemd.user.services.sunshine = {
    after = [ "niri-session.target" ];
    wants = [ "niri-session.target" ];
    wantedBy = [ "niri-session.target" ];
  };

  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
}
