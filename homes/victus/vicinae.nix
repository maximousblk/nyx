{ pkgs, inputs, ... }:
{
  services.vicinae = {
    enable = true;
    package = pkgs.vicinae;

    systemd = {
      enable = true;
      autoStart = true;
      target = "niri-session.target";
    };

    extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
      niri
      nix
      zed-recents
    ];

    settings = {
      close_on_focus_loss = true;
      pop_to_root_on_close = true;
      search_files_in_root = false;
      favicon_service = "twenty";

      telemetry.system_info = false;

      font = {
        rendering = "native";
        normal = {
          family = "IoskeleyMono Nerd Font";
          size = 12;
        };
      };

      # noctalia will override this live via `vicinae theme set noctalia`
      theme.dark = {
        name = "noctalia";
        icon_theme = "auto";
      };

      launcher_window = {
        opacity = 0.9;
        client_side_decorations = {
          enabled = true;
          rounding = 10;
        };
        layer_shell.enabled = true;
        blur.enabled = true;
      };

    };
  };
}
