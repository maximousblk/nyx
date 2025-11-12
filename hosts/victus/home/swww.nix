{ pkgs, pkgx, ... }:
{
  services.swww.enable = true;

  systemd.user.services.wallpaper-changer = {
    Unit = {
      Description = "Randomly change wallpaper with swww";
      After = [ "swww.service" ];
      Requires = [ "swww.service" ];
    };

    Install.WantedBy = [ "niri-session.target" ];

    Service = {
      Type = "oneshot";
      ExecStart =
        let
          script = pkgs.writeShellScript "wallpaper-changer" ''
            WALLPAPER=$(${pkgs.fd}/bin/fd --type f ${pkgx.dharmx-walls} | ${pkgs.coreutils}/bin/shuf -n 1)

            if [ -z "$WALLPAPER" ]; then
              echo "No wallpaper found. Exiting." >&2
              exit 1
            fi

            ${pkgs.swww}/bin/swww img "$WALLPAPER" --transition-type any
          '';
        in
        "${script}";
    };
  };

  systemd.user.timers.wallpaper-changer = {
    Unit.Description = "Timer to randomly change the wallpaper";
    Timer.OnUnitInactiveSec = "5m";
    Install.WantedBy = [ "timers.target" ];
  };
}
