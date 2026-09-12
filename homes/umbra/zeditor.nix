{ ... }: {
  config = {
    home.sessionVariables.VISUAL = "zeditor --wait";

    programs.zed-editor = {
      enable = true;
      mutableUserSettings = false;
      extensions = [
        "nix"
        "toml"
        "make"
        "python"
        "typescript"
        "javascript"
        "go"
      ];

      userSettings = {
        # General
        auto_update = false;
        autosave.after_delay.milliseconds = 2000;
        close_on_file_delete = false;
        on_last_window_closed = "quit_app";
        when_closing_with_no_tabs = "close_window";
        use_system_path_prompts = false;
        use_system_prompts = false;

        # Appearance
        theme = "Zedokai Light";
        ui_font_size = 16;
        buffer_font_family = "IoskeleyMono Nerd Font Mono";
        buffer_font_size = 16;
        text_rendering_mode = "subpixel";
        reduce_motion = "on";
        cursor_shape = "block";
        show_whitespaces = "trailing";
        colorize_brackets = false;
        indent_guides = {
          background_coloring = "disabled";
          coloring = "fixed";
        };
        inlay_hints = {
          enabled = true;
          show_background = false;
        };
        minimap = {
          display_in = "all_editors";
          max_width_columns = 60;
          show = "always";
          thumb = "always";
          thumb_border = "left_open";
        };
        gutter.min_line_number_digits = 0;

        # Keymap
        base_keymap = "VSCode";
        vim_mode = true;
        helix_mode = false;
        vim.toggle_relative_line_numbers = false;
        which_key.enabled = true;

        # Editor
        auto_indent = "preserve_indent";
        auto_signature_help = true;
        autoscroll_on_clicks = false;
        completion_menu_item_kind = "symbol";
        double_click_in_multibuffer = "open";
        horizontal_scroll_margin = 13;
        hover_popover_delay = 1000;
        hover_popover_hiding_delay = 300;
        line_ending = "prefer_lf";
        relative_line_numbers = "disabled";
        reveal_if_open = true;
        scroll_beyond_last_line = "vertical_scroll_margin";
        vertical_scroll_margin = 9;
        soft_wrap = "editor_width";
        sticky_scroll.enabled = true;
        tab_size = 2;
        toolbar.code_actions = true;

        # Languages & Tools
        languages = { };
        load_direnv = "shell_hook";

        # Search & Files
        markdown_preview.limit_content_width = false;
        search = {
          button = false;
          center_on_match = true;
        };
        search_wrap = false;
        seed_search_query_from_cursor = "selection";
        project_panel = {
          bold_folder_labels = false;
          diagnostic_badges = true;
          dock = "left";
          folder_indicator = "icon";
          git_status_indicator = true;
          hide_gitignore = false;
          hide_hidden = false;
          hide_root = true;
          indent_size = 28;
          show_diagnostics = "errors";
        };

        # Window & Layout
        bottom_dock_layout = "right_aligned";
        preview_tabs.enable_preview_multibuffer_from_code_navigation = true;
        status_bar = {
          line_endings_button = true;
          show_active_file = false;
        };
        tab_bar = {
          show = true;
          show_nav_history_buttons = false;
          show_pinned_tabs_in_separate_row = false;
          show_tab_bar_buttons = true;
        };
        tabs = {
          file_icons = true;
          git_status = false;
          show_diagnostics = "off";
        };
        title_bar = {
          button_layout = "platform_default";
          show_branch_name = true;
          show_branch_status_icon = true;
          show_menus = false;
          show_onboarding_banner = false;
          show_project_items = true;
          show_sign_in = false;
          show_user_menu = true;
          show_user_picture = false;
          show_worktree_name = true;
        };
        window_decorations = "server";

        # Panels
        collaboration_panel.button = false;
        outline_panel = {
          button = false;
          dock = "left";
        };

        # Terminal
        terminal = {
          alternate_scroll = "off";
          blinking = "on";
          copy_on_select = false;
          detect_venv.on = {
            activate_script = "default";
            directories = [
              ".env"
              "env"
              ".venv"
              "venv"
            ];
          };
          dock = "bottom";
          env.TERM = "xterm-256color";
          font_family = "IoskeleyMonoTerm Nerd Font Mono";
          font_features.ligatures = true;
          font_size = 16;
          line_height = "comfortable";
          max_scroll_history_lines = 10000;
          option_as_meta = false;
          shell = "system";
          show_count_badge = true;
          toolbar.breadcrumbs = true;
          working_directory = "current_project_directory";
        };

        # Version Control
        git = {
          file_diff.show_full_file = true;
          inline_blame.show_commit_summary = true;
        };
        git_panel = {
          diff_stats = true;
          dock = "left";
          entry_primary_click_action = "file_diff";
          file_icons = false;
          group_by = "none";
          show_count_badge = false;
          tree_view = false;
        };

        # Collaboration
        calls.mute_on_join = true;

        # AI
        agent = {
          button = false;
          dock = "right";
          enable_feedback = false;
          enabled = false;
          sidebar_side = "right";
        };
        disable_ai = true;
        edit_predictions = {
          allow_data_collection = "no";
          mode = "subtle";
        };

        # Network
        read_ssh_config = true;
        ssh_connections = [ ];
        wsl_connections = [
          {
            distro_name = "remora";
            projects = [ { paths = [ "/home/ashwin_y/projects" ]; } ];
          }
        ];

        # Developer
        redact_private_values = true;
        telemetry = {
          diagnostics = false;
          metrics = false;
        };
      };
    };

    xdg.configFile."zed/settings.json".force = true;
  };
}
