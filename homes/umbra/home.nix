{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-index-database.homeModules.nix-index

    ./packages.nix
    ./zeditor.nix
    ./git.nix
  ];

  config = {

    # backupFileExtension = "hm_bak";

    home.username = "ashwin_y";
    home.homeDirectory = "/home/ashwin_y/.local/share/distrobox/umbra_home";
    home.stateVersion = "25.05";

    programs.nix-index-database.comma.enable = true;
    programs.home-manager.enable = true;
    programs.nix-index.enable = true;
    programs.lazydocker.enable = true;

    home.sessionPath = [
      "$HOME/.local/bin"
      "$HOME/bin"
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
      LIBVA_DRIVERS_PATH = "${pkgs.intel-media-driver}/lib/dri";
    };

    programs.sesh = {
      enable = true;
      enableTmuxIntegration = false;
    };

    programs.fzf = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      tmux.enableShellIntegration = true;
    };

    programs.tmux = {
      enable = true;
      shell = "${pkgs.fish}/bin/fish";
      terminal = "tmux-256color";
      historyLimit = 100000;

      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.rose-pine;
          extraConfig = "set -g @rose_pine_variant 'main'";
        }
        tmuxPlugins.better-mouse-mode
      ];

      extraConfig = ''
        set -s escape-time 0

        set-option -g mouse on

        bind-key "^k" display-popup -E -w 40% "sesh connect \"$(
         sesh list -i | gum filter --limit 1 --no-sort --fuzzy --placeholder 'Pick a sesh' --height 50
        )\""
      '';
    };

    programs.bash = {
      enable = true;

      historyControl = [ "ignoreboth" ];
      historySize = 1000;
      historyFileSize = 2000;

      shellOptions = [ "histappend" ];

      shellAliases = {
        ls = "ls --color=auto";
        grep = "grep --color=auto";
        fgrep = "fgrep --color=auto";
        egrep = "egrep --color=auto";
      };

      profileExtra = ''
        if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
          . "$HOME/.nix-profile/etc/profile.d/nix.sh"
        fi
      '';
    };

    programs.zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
      enableFishIntegration = true;
      enableBashIntegration = true;
    };

    services.ollama = {
      enable = true;
      acceleration = false;
    };

    programs.opencode = {
      enable = true;
      settings = {
        theme = "system";
        model = "opencode/big-pickle"; # Current model - free stealth model
        small_model = "opencode/big-pickle";

        # Alternative free models (uncomment to use):
        # model = "opencode/gpt-5-nano";     # Free unlimited, no data collection
        # model = "opencode/grok-code";       # Free (limited time), collects data for improvement

        autoupdate = false;
        share = "disabled";

        permission = {
          # Destructive operations - always ask
          bash = "ask";
          edit = "ask";
          write = "ask";
          patch = "ask";
          todowrite = "ask";

          # Safe operations - always allow
          read = "allow";
          grep = "allow";
          glob = "allow";
          list = "allow";
          todoread = "allow";
          webfetch = "allow";
        };
      };
    };

    fonts.fontconfig.enable = true;
  };
}
