{ config, ... }:
{

  config = {
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          immediate_render = true;
          hide_cursor = true;
        };

        background = [
          {
            monitor = "";
            path = config.optx.wallpapers.paths.current;
            blur_passes = 2;
            blur_size = 4;
          }
        ];

        input-field = [
          {
            monitor = "";
            size = "176, 64";
            outline_thickness = 2;
            dots_size = 0.3;
            dots_spacing = 0.6;
            dots_center = true;

            outer_color = "rgba(0, 0, 0, 0)";
            inner_color = "rgba(0, 0, 0, 0.2)";
            font_color = "rgb(255, 255, 255)";
            check_color = "rgb(70, 200, 200)";
            fail_color = "rgb(204, 34, 34)";

            fade_on_empty = true;
            placeholder_text = "Enter Pin";
            hide_input = false;

            position = "0, -200";
            halign = "center";
            valign = "center";
          }
        ];

        label = [
          {
            monitor = "";
            text = "$TIME";
            color = "rgba(255, 255, 255, 0.8)";
            font_size = 120;
            font_family = "JetBrains Mono ExtraBold";
            position = "0, 0";
            halign = "center";
            valign = "center";

            shadow_passes = 1;
            shadow_size = 1;
            shadow_color = "rgb(0,0,0)";
            shadow_boost = 0.2;
          }
        ];
      };
    };
  };
}
