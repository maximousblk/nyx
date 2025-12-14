{
  pkgs,
  pkgx,
  inputs,
  ...
}:
{

  imports = [
    inputs.vicinae.homeManagerModules.default
    inputs.nix-index-database.homeModules.nix-index
    inputs.sops-nix.homeManagerModules.sops

    ./niri.nix
    ./waybar.nix
    ./ironbar.nix
    ./swww.nix
    ./cursor.nix
    ./browser.nix
    ./hyprlock.nix
    ./hypridle.nix
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
    bitwarden-desktop
    playerctl
    pulseaudio
    hyprpwcenter

    gparted
    kdePackages.dolphin
    peazip
    rar

    lutris
    protonup-qt
    wine
    winetricks
    uxplay
    exfatprogs

    libappindicator-gtk3

    adwaita-icon-theme
    hicolor-icon-theme
    nil
    nixd
    zed-editor
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
