{ ... }: {

  services.udiskie.enable = true;

  wayland.windowManager.niri = {
    enable = true;
    extraConfig = builtins.readFile ./niri.config.kdl;
    # NixOS owns the session units, Xwayland, and portals.
    systemd.enable = false;
    xwaylandSatellitePackage = null;
    portalPackage = null;
  };
}
