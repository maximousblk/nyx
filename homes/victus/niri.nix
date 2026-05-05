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

  xdg.configFile."niri/config.kdl".text = builtins.readFile ./niri.config.kdl + ''
    // Notify all dependencies that Niri has started
    spawn-sh-at-startup "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all && ${pkgs.systemd}/bin/systemctl --user start niri-session.target"
  '';
}
