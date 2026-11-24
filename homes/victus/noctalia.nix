{
  config,
  inputs,
  pkgs,
  ...
}:
let
  onBattery = ''[ "$(${pkgs.systemd}/bin/busctl --system get-property org.freedesktop.UPower /org/freedesktop/UPower org.freedesktop.UPower OnBattery)" = "b true" ]'';
in
{

  home.file."wallpapers" = {
    enable = true;
    source = config.optx.wallpapers.package;
    target = "Pictures/Wallpapers/.base";
  };

  programs.noctalia = {
    enable = true;
    systemd.enable = true;

    settings = {
      accessibility.ui_scale = 1.0;

      plugins = {
        enabled = [ ];
        auto_update = "none";
        source = [
          {
            name = "community";
            kind = "path";
            location = "${inputs.noctalia-community-plugins}";
            enabled = true;
          }
        ];
      };

      shell = {
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
          size = 12;
        };

        panel = {
          transparency_mode = "glass";
          borders = true;
          shadow = false;
          launcher_placement = "floating";
          launcher_position = "center";
          clipboard_placement = "floating";
          clipboard_position = "center";
          control_center_placement = "floating";
          wallpaper_placement = "floating";
          wallpaper_position = "center";
          session_placement = "floating";
          session_position = "center";
          open_near_click_control_center = true;
        };

        mpris.blacklist = [ ];
        privacy.mic_filter_regex = "Studio Voice Source";
        screenshot = {
          save_to_file = false;
        };

      };

      lockscreen = {
        enabled = true;
        allow_empty_password = false;
        blurred_desktop = false;
        blur_intensity = 0.0;
        fingerprint = false;
        lock_before_suspend = true;
        monitors = [ ];
        tint_intensity = 0.0;
        wallpaper = "";
      };

      lockscreen_widgets = {
        enabled = true;
        schema_version = 2;
        widget_order = [
          "lockscreen-login-box@eDP-1"
          "lockscreen-widget-0000000000000001"
        ];
        grid = {
          cell_size = 8;
          major_interval = 4;
          visible = true;
        };
        widget = {
          "lockscreen-login-box@eDP-1" = {
            box_height = 196.0;
            box_width = 720.0;
            cx = 960.0;
            cy = 894.0;
            enabled = true;
            output = "eDP-1";
            placement_height = 1080.0;
            placement_width = 1920.0;
            rotation = 0.0;
            type = "login_box";
            settings = {
              background_color = "surface_variant";
              background_opacity = 0.88;
              background_radius = 12.0;
              center_password_text = false;
              input_opacity = 1.0;
              input_radius = 6.0;
              layout = "regular";
              show_caps_lock = true;
              show_keyboard_layout = true;
              show_login_button = true;
              show_media = true;
              show_session_buttons = true;
              show_unlock_hint = true;
              show_weather = true;
            };
          };
          lockscreen-widget-0000000000000001 = {
            box_height = 104.0;
            box_width = 256.0;
            cx = 960.0;
            cy = 72.0;
            enabled = true;
            output = "eDP-1";
            placement_height = 1080.0;
            placement_width = 1920.0;
            rotation = 0.0;
            type = "clock";
            settings = {
              background = false;
              shadow = true;
            };
          };
        };
      };

      audio = {
        enable_overdrive = true;
        enable_sounds = true;
        sound_volume = 1.0;
      };

      theme = {
        mode = "dark";
        shell_mode = "follow";
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
          enable_community_templates = true;
          community_ids = [
            "prismlauncher"
            "vicinae"
            "fastfetch"
            "herdr"
          ];
        };
      };

      location = {
        auto_locate = false;
        address = "Delhi, IN";
      };

      weather = {
        enabled = true;
        effects = true;
        unit = "celsius";
      };

      idle = {
        # Noctalia fades before the command can check the power source.
        pre_action_fade_seconds = 0.0;
        behavior = {
          screen-off = {
            enabled = true;
            timeout = 300;
            action = "command";
            command = "${onBattery} && noctalia msg dpms-off";
            resume_command = "noctalia msg dpms-on";
          };
          lock = {
            enabled = true;
            timeout = 600;
            action = "command";
            command = "${onBattery} && noctalia msg session lock";
          };
        };
      };

      wallpaper = {
        enabled = true;
        fill_mode = "crop";
        fill_color = "#000000";
        directory = "${config.home.homeDirectory}/Pictures/Wallpapers/.base";
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
        width = 700;
        hidden_tabs = [ ];
        show_session_button = true;
        show_shortcut_labels = true;
        shortcuts = [
          { type = "wifi"; }
          { type = "bluetooth"; }
          { type = "caffeine"; }
          { type = "nightlight"; }
          { type = "notification"; }
          { type = "power_profile"; }
        ];
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
        border = "outline_variant";
        shadow = false;
        margin_edge = 4;
        margin_ends = 4;
        padding = 4;
        radius = 6;
        thickness = 32;
        panel_overlap = 0;
        scale = 1.0;
        font_weight = 600;
        capsule = true;
        capsule_fill = "surface_container";
        capsule_thickness = 0.76;
        capsule_opacity = 0.0;
        capsule_padding = 4.0;
        capsule_radius = 4;
        actions.middle = "none";
        start = [
          "workspaces"
          "active_window"
        ];
        center = [ ];
        end = [
          "media"
          "tray"
          "privacy"
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
          show_labels = false;
          max_label_chars = 1;
          labels_only_when_occupied = false;
          hide_when_empty = false;
        };
        privacy.hide_inactive = true;
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
        layer = "top";
        auto_hide = false;
        smart_auto_hide = true;
        reserve_space = false;
        background_opacity = 0.9;
        border = "outline_variant";
        border_width = 0.0;
        margin_edge = 4;
        margin_ends = 4;
        main_axis_padding = 4;
        cross_axis_padding = 4;
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
