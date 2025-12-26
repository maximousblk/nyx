{ pkgs, lib, ... }:
{
  config = {
    home.sessionVariables = {
      VISUAL = "zeditor";
    };

    programs.zed-editor = {
      enable = true;
      extensions = [
        "nix"
        "toml"
        "make"
        "rust"
        "python"
        "typescript"
        "javascript"
        "go"
      ];

      userSettings = {
        auto_update = false;
        telemetry.diagnostics = false;
        telemetry.metrics = false;

        ui_font_family = "JetBrainsMono Nerd Font Propo";
        ui_font_size = 16;

        buffer_font_family = "JetBrainsMono Nerd Font Propo";
        buffer_font_size = 16;

        terminal.font_family = "JetBrainsMono Nerd Font";
        terminal.font_size = 16;
        terminal.font_features.ligatures = true;

        redact_private_values = true;
        use_system_path_prompts = false;
        use_system_prompts = false;

        ssh_connections = [
          {
            host = "editing-metrics-server-gpu";
            projects = [ { paths = [ "/home/aftershoot/editing-metrics-server" ]; } ];
          }
        ];

        autosave.after_delay.milliseconds = 1000;

        title_bar = {
          show_onboarding_banner = false;
          show_branch_icon = true;
          show_branch_name = true;
          show_project_items = true;
          show_sign_in = false;
          show_user_picture = false;
        };

        agent = {
          enabled = false;
          always_allow_tool_actions = true;
          expand_edit_card = false;
          expand_terminal_card = false;

          default_model = {
            provider = "copilot_chat";
            model = "gpt-5";
          };

          inline_alternatives = [
            {
              provider = "copilot_chat";
              model = "gpt-5";
            }
          ];
        };

        auto_install_extensions = {
          make = true;
          nix = true;
          toml = true;
          go = true;
          javascript = true;
          python = true;
          rust = true;
          typescript = true;
        };

        autoscroll_on_clicks = false;

        calls.mute_on_join = true;
        collaboration_panel.button = false;

        double_click_in_multibuffer = "open";

        edit_predictions.mode = "subtle";
        horizontal_scroll_margin = 13;

        notification_panel.button = false;
        outline_panel.button = false;

        project_panel = {
          hide_gitignore = false;
          hide_hidden = false;
          indent_size = 28;
        };

        scroll_beyond_last_line = "vertical_scroll_margin";
        vertical_scroll_margin = 9;

        node = {
          path = lib.getExe pkgs.nodejs;
          npm_path = lib.getExe' pkgs.nodejs "npm";
        };

        terminal = {
          alternate_scroll = "off";
          blinking = "off";
          copy_on_select = false;
          dock = "bottom";
          detect_venv = {
            on = {
              directories = [
                ".env"
                "env"
                ".venv"
                "venv"
              ];
              activate_script = "default";
            };
          };

          env = {
            TERM = "xterm-256color";
          };

          line_height = "comfortable";
          option_as_meta = false;
          shell = "system";
          working_directory = "current_project_directory";

          toolbar.breadcrumbs = true;
          max_scroll_history_lines = 10000;
        };

        lsp = {
          rust-analyzer.binary.path = lib.getExe pkgs.rust-analyzer;
          nix.binary.path = lib.getExe pkgs.nixd;
        };

        languages = { };
        vim_mode = true;
        load_direnv = "shell_hook";
        base_keymap = "VSCode";
        theme = {
          mode = "system";
          light = "One Light";
          dark = "One Dark";
        };
        show_whitespaces = "trailing";
      };
    };
  };
}
