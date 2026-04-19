{
  pkgs,
  pkgx,
  modx,
  config,
  victus,
  ...
}:
{

  imports = [
    ./niri.nix
    ./browser.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./vicinae.nix
    ./noctalia.nix
    # ./waybar.nix
    # ./ironbar.nix
    # ./swww.nix
    # ./mako.nix

    modx.hm.clanker
    modx.hm.wallpaper
  ];

  optx.clanker = {
    opencode.enable = true;
    claude.enable = true;
    ollama.enable = true;
    ollama.acceleration = "cuda";
  };

  optx.wallpapers = {
    enable = true;
    package = pkgx.dharmx-walls;
  };

  home.username = victus.username;
  home.homeDirectory = victus.homeDirectory;
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    pkgx.polycat

    adwaita-icon-theme
    bitwarden-cli
    bitwarden-desktop
    btop-cuda
    chafa
    duf
    exfatprogs
    felix-fm
    gh
    hicolor-icon-theme
    hyprpwcenter
    jq
    kdePackages.ark
    kdePackages.breeze-icons
    kdePackages.dolphin
    kdePackages.filelight
    kdePackages.gwenview
    kdePackages.kdeconnect-kde
    kdePackages.partitionmanager
    kdePackages.qtsvg
    libappindicator
    lutris
    mindustry-wayland
    ncdu
    nil
    nixd
    nvtopPackages.full
    p7zip
    playerctl
    protonplus
    pulseaudio
    rar
    rose-pine-icon-theme
    sqlite
    tmux
    tree
    uxplay
    winetricks
    wineWow64Packages.waylandFull
    zed-editor
    zoxide
  ];

  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";

    cursor = {
      package = pkgs.rose-pine-cursor;
      name = "BreezeX-RosePine-Linux";
      size = 32;
    };

    image = null;

    targets = {
      zen-browser.profileNames = [ "default" ];
      hyprlock.enable = false;
      noctalia-shell.enable = false;
      ghostty.colors.enable = false;
      fish.enable = false;
      opencode.enable = false;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Propo";
      };
    };
  };

  home.sessionVariables = {
    XCURSOR_PATH = "${config.home.homeDirectory}/.local/share/icons";
  };

  programs.man = {
    enable = true;
    generateCaches = false;
  };

  programs.git = {
    enable = true;
    settings.user.name = "maximousblk";
    settings.user.email = "maximousblk@gmail.com";
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        identityFile = [ "~/.ssh/id_ed25519" ];
      };
    };
  };

  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    systemd.enable = true;
    settings = {
      theme = "noctalia";
      command = "${config.programs.fish.package}/bin/fish";
      shell-integration-features = "ssh-terminfo,ssh-env";
      window-theme = "ghostty";
      window-padding-x = "2";
      window-padding-y = "2";
      window-padding-balance = true;
    };
  };

  programs.fish = {
    enable = true;
    package = pkgs.fish;
  };

  programs.zoxide = {
    enable = true;
    options = [ "--cmd cd" ];
    enableFishIntegration = true;
    enableBashIntegration = true;
  };

  programs.zed-editor = {
    enable = true;

    ## This populates the userSettings "auto_install_extensions"
    extensions = [
      "nix"
      "toml"
      "elixir"
      "make"
    ];

    ## everything inside of these brackets are Zed options.
    userSettings = {
      vim_mode = true;
      buffer_font_family = "JetBrainsMono Nerd Font Propo";
      languages.Nix.language_servers = [
        "nil"
        "!nixd"
      ];

      lsp.nil.initialization_options.formatting.command = [ "return" ];
    };
  };

  services.tailscale-systray.enable = true;

  programs.mangohud.enable = true;

  systemd.user.services.uxplay = {
    Unit = {
      Description = "AirPlay Unix mirroring server";
      After = [
        "network.target"
        "niri-session.target"
      ];
      Wants = [ "niri-session.target" ];
    };
    Install = {
      WantedBy = [ "niri-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.uxplay}/bin/uxplay";
      Restart = "on-failure";
    };
  };
}
