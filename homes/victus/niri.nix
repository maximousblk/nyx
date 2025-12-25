{ pkgs, ... }:
{

  services.gnome-keyring.enable = true;
  services.polkit-gnome.enable = true;
  services.udiskie.enable = true;

  systemd.user.targets.niri-session = {
    Unit = {
      Description = "Niri Session";
      BindsTo = [ "graphical-session.target" ];
      After = [ "graphical-session-pre.target" ];
      Wants = [ "graphical-session-pre.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  xdg.configFile."niri/config.kdl".text = builtins.readFile ./niri.config.kdl + ''
    // Notify all dependencies that Niri has started
    spawn-sh-at-startup "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP && ${pkgs.systemd}/bin/systemctl --user start niri-session.target"
  '';
}
