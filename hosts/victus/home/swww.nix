{
  lib,
  pkgs,
  pkgx,
  modx,
  config,
  ...
}:
{
  imports = [ modx.hm.wallpaper ];

  config = {
    optx.wallpapers = {
      enable = true;
      package = pkgx.dharmx-walls;
    };

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
        ExecStart = lib.getExe (
          pkgs.writeShellApplication {
            name = "change-wallpaper";
            runtimeInputs = [
              pkgs.findutils
              pkgs.coreutils
              pkgs.swww
            ];
            text = ''
              WALLPAPER=$(find -L "${config.optx.wallpapers.paths.collection}" -type f | shuf -n 1)

              if [ -z "$WALLPAPER" ]; then
                echo "No wallpapers found in ${config.optx.wallpapers.paths.collection}"
                exit 1
              fi

              ln -sfn "$WALLPAPER" "${config.optx.wallpapers.paths.current}"

              swww img "${config.optx.wallpapers.paths.current}" --transition-type any
            '';
          }
        );
      };
    };

    systemd.user.timers.wallpaper-changer = {
      Unit.Description = "Timer to randomly change the wallpaper";
      Timer.OnUnitInactiveSec = "5m";
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
