{ pkgs, ... }:
let
  wallpaperRepo = pkgs.fetchFromGitHub {
    owner = "dharmx";
    repo = "walls";
    rev = "6bf4d733ebf2b484a37c17d742eb47e5139e6a14"; # 2025.10.25
    hash = "sha256-M96jJy3L0a+VkJ+DcbtrRAquwDWaIG9hAUxenr/TcQU=";
  };
in
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
            WALLPAPER=$(${pkgs.fd}/bin/fd --type f \
              --extension jpg \
              --extension jpeg \
              --extension png \
              --extension webp \
              . ${wallpaperRepo} | ${pkgs.coreutils}/bin/shuf -n 1)

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
