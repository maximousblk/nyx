{
  pkgs,
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.nix-index-database.homeModules.nix-index

    ./packages.nix
    ./zeditor.nix
    ./git.nix
    ./clanker.nix
  ];

  config = {
    home.stateVersion = "25.05";

    home.sessionPath = [
      "$HOME/.local/bin"
      "$HOME/bin"
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
      LIBVA_DRIVERS_PATH = "${pkgs.intel-media-driver}/lib/dri";
      DOCKER_HOST = "unix:///run/host/run/user/1000/podman/podman.sock";
      CONTAINER_HOST = "unix:///run/host/run/user/1000/podman/podman.sock";
      PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    };

    home.shell = {
      enableBashIntegration = true;
      enableFishIntegration = true;
    };

    programs.nix-index-database.comma.enable = true;
    programs.home-manager.enable = true;
    programs.nix-index.enable = true;
    programs.lazydocker.enable = true;

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

    programs.fish = {
      enable = true;
      package = pkgs.fish;

      functions = {
        prompt_hostname = ''
          string replace -r -- "\..*" "" $CONTAINER_ID
        '';
      };
    };

    programs.tmux = {
      enable = true;
      shell = "${config.programs.fish.package}/bin/fish";
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
        setw -g mode-keys vi
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

      initExtra = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${config.programs.fish.package}/bin/fish $LOGIN_OPTION
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

    fonts.fontconfig.enable = true;
  };
}
