{
  pkgs,
  pkgx,
  inputs,
  ...
}:
{

  imports = [
    inputs.vicinae.homeManagerModules.default

    ./niri.nix
    ./waybar.nix
    ./ironbar.nix
    ./swww.nix
    ./cursor.nix
    ./browser.nix
  ];

  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    pkgx.polycat

    ncdu
    tree
    btop
    ghostty
    nvtopPackages.full
    jq
    bitwarden-cli
    playerctl
    pulseaudio

    gparted
    kdePackages.dolphin

    lutris
    protonup-qt
    wine
    winetricks
    uxplay
    exfatprogs

    libappindicator-gtk3

    adwaita-icon-theme
    hicolor-icon-theme
  ];

  gtk = {
    enable = true;

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = "rose-pine";
      package = pkgs.rose-pine-gtk-theme;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
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

  programs.discord = {
    enable = true;
    settings = {
      SKIP_HOST_UPDATE = true;
      IS_MAXIMIZED = true;
      enableHardwareAcceleration = true;
    };
  };

  programs.zapzap = {
    enable = true;
    settings = {
      notification = {
        donation_message = true;
      };

      performance = {
        in_process_gpu = true;
        single_process = true;
      };

      system = {
        scale = 100;
        theme = "auto";
        menubar = false;
        sidebar = false;
        wayland = true;
        quit_in_close = true;
      };

      website.open_page = false;
      web.scroll_animator = true;
    };
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
    };
  };

  xdg.configFile."vicinae/vicinae.json".force = true;
  services.vicinae = {
    enable = true; # default: false
    autoStart = true; # default: true
    settings = {
      faviconService = "twenty"; # twenty | google | none
      font.normal = "JetBrainsMono Nerd Font Propo";
      font.size = 12;
      popToRootOnClose = true;
      rootSearch.searchFiles = false;
      theme.name = "kanagawa";
      window = {
        csd = true;
        opacity = 0.95;
        rounding = 10;
      };
    };
  };

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
