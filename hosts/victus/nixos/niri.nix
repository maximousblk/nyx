{ lib, pkgs, ... }: {
  programs.niri = {
    enable = true;
    useNautilus = false;
  };
  programs.xwayland.enable = true;

  services.gnome.at-spi2-core.enable = true;

  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  environment.systemPackages = with pkgs; [
    bitwarden-desktop
    xwayland-satellite
    kdePackages.dolphin
  ];

  xdg.portal = {
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    config.niri = {
      "org.freedesktop.impl.portal.FileChooser" = lib.mkForce [
        "kde"
        "gtk"
      ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
    };
  };
}
