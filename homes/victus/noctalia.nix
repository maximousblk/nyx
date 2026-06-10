{ config, pkgs, ... }: {

  home.file."wallpapers" = {
    enable = true;
    source = config.optx.wallpapers.package;
    target = "Pictures/Wallpapers/.base";
  };

  programs.noctalia = {
    enable = true;
    systemd.enable = true;

    settings = {
      shell = {
        ui_scale = 1.0;
        corner_radius_scale = 0.5;
        font_family = "IoskeleyMono Nerd Font";
        lang = "";
        telemetry_enabled = false;
        setup_wizard_enabled = false;
        settings_show_advanced = true;
        niri_overview_type_to_launch_enabled = false;
        avatar_path = "/home/maximousblk/.face";
        launch_apps_as_systemd_services = true;
        app_icon_colorize = false;
        clipboard_enabled = false;
        middle_click_opens_widget_settings = false;
        password_style = "default";
        polkit_agent = true;
        screen_time_enabled = true;

        animation = {
          enabled = true;
          speed = 2.0;
        };

        shadow = {
          direction = "center";
          alpha = 0.0;
        };

        screen_corners = {
          enabled = true;
          size = 6;
        };

        panel = {
          transparency_mode = "glass";
          borders = true;
          shadow = false;
          launcher_placement = "centered";
          clipboard_placement = "centered";
          control_center_placement = "floating";
          open_near_click_control_center = true;
          wallpaper_placement = "centered";
          session_placement = "centered";
        };

        mpris.blacklist = [ ];
        screenshot = {
          save_to_file = false;
        };

      };

      lockscreen = {
        blurred_desktop = false;
        blur_intensity = 0.0;
        tint_intensity = 0.0;
        wallpaper = "";
      };

      audio = {
        enable_overdrive = false;
        enable_sounds = true;
        sound_volume = 1.0;
      };

      theme = {
        mode = "dark";
        source = "wallpaper";
        builtin = "Rosé Pine";
        wallpaper_scheme = "m3-rainbow";
        templates = {
          enable_builtin_templates = true;
          builtin_ids = [
            "btop"
            "ghostty"
            "niri"
          ];
          enable_community_templates = false;
          community_ids = [ ];
        };
      };

      location = {
        auto_locate = false;
        address = "Delhi, IN";
      };

      weather = {
        enabled = true;
        effects = true;
        unit = "metric";
      };

      idle = {
        pre_action_fade_seconds = 5.0;
        behavior = {
          screen-off = {
            enabled = true;
            timeout = 300;
            command = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10%";
            resume_command = "${pkgs.brightnessctl}/bin/brightnessctl -r";
          };
          lock = {
            enabled = true;
            timeout = 600;
            command = "noctalia:session lock";
          };
        };
      };

      wallpaper = {
        enabled = true;
        fill_mode = "crop";
        fill_color = "#000000";
        directory = "${config.home.homeDirectory}/Pictures/Wallpapers";
        per_monitor_directories = false;
        transition = [ "disc" ];
        transition_duration = 4000;
        edge_smoothness = 0.1;
        transition_on_startup = true;
        automation = {
          enabled = true;
          interval_seconds = 300;
          order = "random";
          recursive = true;
        };
      };

      backdrop = {
        enabled = false;
        blur_intensity = 0.5;
        tint_intensity = 0.35;
      };

      brightness = {
        enable_ddcutil = true;
      };

      control_center = {
        sidebar = "compact";
        sidebar_section = "none";
      };

      desktop_widgets = {
        enabled = false;
      };

      notification = {
        position = "bottom_right";
      };

      osd = {
        offset_y = 36;
        position = "bottom_center";
      };

      system.monitor = {
        enabled = false;
      };

      bar.default = {
        enabled = true;
        position = "top";
        layer = "top";
        auto_hide = false;
        reserve_space = true;
        background_opacity = 0.9;
        border_width = 0.0;
        shadow = false;
        margin_edge = 4;
        margin_ends = 4;
        padding = 4;
        radius = 4;
        thickness = 32;
        panel_overlap = 0;
        scale = 1.0;
        font_weight = 600;
        capsule = true;
        capsule_opacity = 0.0;
        capsule_padding = 4.0;
        capsule_radius = 4;
        start = [
          "workspaces"
          "active_window"
        ];
        center = [ ];
        end = [
          "media"
          "tray"
          "volume"
          "network"
          "battery"
          "notifications"
          "clock"
          "control-center"
        ];
      };

      widget = {
        workspaces = {
          display = "none";
          minimal = false;
          max_label_chars = 1;
          labels_only_when_occupied = false;
          hide_when_empty = false;
        };
        active_window = {
          display = "icon_and_text";
          max_length = 800.0;
          title_scroll = "on_hover";
        };
        media = {
          max_length = 300.0;
          title_scroll = "on_hover";
          hide_when_no_media = true;
        };
        tray = {
          drawer = true;
          drawer_columns = 5;
          match_adjacent_spacing = true;
          pinned = [ "tailscale" ];
          hidden = [ ];
        };
        volume = {
          scroll_step = 5;
          show_label = false;
        };
        network.show_label = false;
        battery = {
          display_mode = "glyph";
          hide_when_full = true;
          show_label = false;
          device = "auto";
        };
        notifications.hide_when_no_unread = true;
        clock = {
          format = "{:%H:%M %a, %b %d}";
          vertical_format = "{:%H\\n%M - %d\\n%m}";
          tooltip_format = "{:%H:%M %a, %b %d}";
        };
        control-center = {
          glyph = "menu";
        };
      };

      dock = {
        enabled = true;
        position = "bottom";
        auto_hide = true;
        reserve_space = false;
        background_opacity = 0.0;
        margin_edge = 8;
        icon_size = 36;
        active_monitor_only = true;
        magnification = true;
        magnification_scale = 1.2;
        active_scale = 1.0;
        inactive_scale = 0.85;
        active_opacity = 1.0;
        inactive_opacity = 0.85;
        radius = 6;
        shadow = false;
        show_dots = true;
        show_instance_count = false;
        pinned = [ ];
      };
    };
  };
}
