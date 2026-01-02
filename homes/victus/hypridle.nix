{
  pkgs,
  lib,
  config,
  ...
}:
{
  services.hypridle = {
    enable = true;

    settings = {
      general = {
        lock_cmd = "pidof hyprlock || ${lib.getExe config.programs.hyprlock.package}";
        before_sleep_cmd = "${pkgs.systemd}/bin/loginctl lock-session";
        after_sleep_cmd = "${pkgs.niri}/bin/niri msg action power-on-monitors";
      };

      listener = [
        {
          # 1. Dim Screen
          timeout = 300; # 5min
          on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10";
          on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -r";
        }

        {
          # 1. Dim Screen
          timeout = 300; # 5min
          on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -sd rgb:kbd_backlight set 10";
          on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -rd rgb:kbd_backlight";
        }

        {
          # 2. Lock Screen
          timeout = 600; # 10min
          on-timeout = "${pkgs.systemd}/bin/loginctl lock-session";
        }

        # {
        #   # 3. Turn Off Screen
        #   timeout = 630; # 10.5min
        #   on-timeout = "${pkgs.niri}/bin/niri msg action power-off-monitors";
        #   on-resume = "${pkgs.niri}/bin/niri msg action power-on-monitors";
        # }

        # {
        #   # 4. Suspend
        #   timeout = 1200; # 20min
        #   on-timeout = "${pkgs.systemd}/bin/systemd-ac-power || ${pkgs.systemd}/bin/systemctl suspend";
        # }
      ];
    };
  };
}
