{ pkgs, ... }:
{

  services.gnome-keyring.enable = true;
  services.polkit-gnome.enable = true;
  services.udiskie.enable = true;

  systemd.user.targets.niri-session = {
    Unit = {
      Description = "Niri Session";
      BindsTo = [ "graphical-session.target" ];
      Requires = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      Wants = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  home.sessionVariables = {
    # Electron apps to use Wayland automatically
    ELECTRON_OZONE_PLATFORM_HINT = "auto";

    # Force QT to use Wayland
    QT_QPA_PLATFORM = "wayland";

    # Disable server-side decorations for QT (Niri handles this)
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    # Inform apps (like Portals/Firefox) that we are in Niri
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";

    # Fix for KDE apps (Dolphin/Ark) to populate menus correctly outside Plasma
    XDG_MENU_PREFIX = "plasma-";

    # Zed Editor specific
    ZED_WINDOW_DECORATIONS = "server";
  };

  xdg.configFile."niri/config.kdl".text = builtins.readFile ./niri.config.kdl + ''
    // Notify all dependencies that Niri has started
    spawn-sh-at-startup "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP && ${pkgs.systemd}/bin/systemctl --user start niri-session.target"
  '';
}
