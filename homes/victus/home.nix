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
    kdePackages.filelight
    kdePackages.gwenview
    kdePackages.kdeconnect-kde
    kdePackages.partitionmanager
    kdePackages.qtsvg
    libappindicator
    lutris
    mindustry-wayland
    ncdu
    nh
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

  home.pointerCursor = {
    package = pkgs.rose-pine-cursor;
    name = "BreezeX-RosePine-Linux";
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
    style.package = [
      pkgs.adwaita-qt
      pkgs.adwaita-qt6
    ];
  };

  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  fonts.fontconfig.enable = true;

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

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "nemo.desktop";
      "application/x-gnome-saved-search" = "nemo.desktop";
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
