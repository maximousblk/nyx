{ inputs, ... }:
{

  imports = [ inputs.ironbar.homeManagerModules.default ];

  config = {
    programs.ironbar = {
      enable = true;
      systemd = true;

      config = {
        position = "top";
        height = 28;

        margin = {
          top = 4;
          bottom = 0;
          left = 4;
          right = 4;
        };

        start = [
          {
            type = "workspaces";
            sort = "added";

            name_map.home = "";
            name_map.chat = "";
          }
          # {
          #   type = "launcher";
          #   favorites = [ ];
          #   show_names = false;
          #   show_icons = true;
          #   reversed = false;
          # }
          {
            type = "focused";
            icon_size = 16;
          }
        ];

        center = [ ];

        end = [
          {
            type = "music";
            format = "{artist}";
            truncate = "end";

            icons.play = "";
            icons.pause = "";

            on_click_middle = "playerctl stop";
          }

          {
            type = "custom";
            name = "flyout";

            bar = [
              {
                type = "button";
                label = "";
                on_click = "popup:toggle";
              }
            ];

            popup = [
              {
                type = "clipboard";
                max_items = 5;
                truncate.mode = "middle";
                truncate.length = 50;
              }
              {
                type = "tray";
                icon_size = 24;
              }
              {
                type = "bluetooth";
                icon_size = 24;
              }

              {
                type = "network_manager";
                icon_size = 24;
              }
              {
                type = "battery";
                show_if = "[ -d /sys/class/power_supply/BAT0 ]";
              }
            ];
          }

          {
            type = "script";
            name = "polycat";
            cmd = "polycat";
            mode = "watch";
          }
          {
            type = "volume";
            format = "{icon} {percentage}%";
            max_volume = 100;
            truncate = "end";

            icons.volume_high = "󰕾";
            icons.volume_medium = "󰖀";
            icons.volume_low = "󰕿";
            icons.muted = "󰝟";

            smooth_scroll_speed = 15;
            on_scroll_up = "pactl set-sink-volume @DEFAULT_SINK@ +5%";
            on_scroll_down = "pactl set-sink-volume @DEFAULT_SINK@ -5%";
          }

          {
            type = "clock";
            format = "%H:%M %d %b";
          }
        ];
      };

      style = ''
        /* --- Global Styles --- */
        * {
            font-family: "JetBrainsMono Nerd Font Propo", FontAwesome;
            font-size: 14px;
            border: none;
            border-radius: 0;
            min-height: 0;
        }

        /* --- Main Bar Styling --- */
        /* This makes the outer window transparent to allow for rounded corners */
        window {
            background-color: transparent;
        }

        /* This is the main content box with your background and radius */
        #bar {
            background: rgba(3, 7, 18, 0.9);
            color: rgba(255, 255, 255, 1);
            border-radius: 6px;
        }

        /* --- General Module Styling --- */
        /* Adds padding to all direct modules on the bar */
        #start > *, #center > *, #end > * {
            padding: 0 8px;
        }

        button {
            background-color: transparent;
            background-image: none;
            padding: 0 8px;
        }

        /* General hover effect for all buttons */
        button:hover {
            background: rgba(38, 33, 69, 0.8);
        }

        /* --- Specific Module Styles --- */

        /* Workspaces Module */
        .workspaces .item {
            padding: 4px 6px;
            margin: 0 2px;
            background-color: transparent;
        }

        .workspaces .item.focused {
            color: rgba(109, 103, 218, 0.8);
            background: rgb(38, 33, 69);
        }

        .workspaces .item.visible {
            box-shadow: inset 0 -1px #ffffff;
        }

        .workspaces .item.urgent {
            background-color: #8f0a0a;
        }

        /* Focused Window Module */
        .focused {
            padding-left: 12px;
        }

        /* Music Module */
        .music {
            /* Uses general module padding */
        }

        /* Polycat Custom Script */
        #polycat {
            font-family: "polycat";
            font-size: 18px;
            padding: 0 8px;
        }

        /* Volume Module */
        .volume {
            /* Uses general module padding */
        }

        /* Clock Module */
        .clock {
            font-weight: bold;
        }


        /* --- Flyout Tray Custom Module --- */

        /* The button on the bar */
        #flyout button {
            padding: 0 10px;
        }

        /* The popup window for the flyout */
        #popup-flyout {
            padding: 8px;
        }

        /* Style the tray icons inside the popup for better spacing and feedback */
        #popup-flyout .tray .item {
            padding: 4px;
            margin: 2px;
        }

        #popup-flyout .tray .item:hover {
            border-radius: 4px;
        }

        /* Give other modules inside the flyout some basic spacing */
        #popup-flyout > .widget-container + .widget-container {
            margin-top: 8px;
        }

        /* --- Popup Styling (General) --- */
        /* Generic style for all popups */
        popover {

            border-radius: 6px;
        }

        /* Clock Popup Calendar */
        .popup-clock {
            padding: 10px;
        }
        .popup-clock .calendar .today {
            color: #000;
            border-radius: 4px;
        }
      '';
    };

    systemd.user.services.ironbar = {
      Unit = {
        After = [ "niri-session.target" ];
      };
      Install = {
        WantedBy = [ "niri-session.target" ];
      };
    };
  };
}
