{
  pkgs,
  inputs,
  ...
}:
{

  imports = [
    inputs.zen-browser.homeModules.beta
    inputs.vicinae.homeManagerModules.default

    ./niri.nix
    ./waybar.nix
    ./swww.nix
    ./cursor.nix
  ];

  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    ncdu
    tree
    btop
    ghostty
    nvtopPackages.full
    jq
    bitwarden-cli
    playerctl

    gparted
    kdePackages.dolphin

    discord
    zapzap

    lutris
    protonup-qt
    wine
    winetricks
    uxplay
    exfatprogs
  ];

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

  programs.zen-browser = {
    enable = false;
    policies = {
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
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
