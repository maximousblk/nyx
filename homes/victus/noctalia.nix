{ config, ... }:
{
  programs.noctalia-shell = {
    enable = true;

    systemd.enable = true;

    settings = {
      general = {
        avatarImage = "/home/maximousblk/.face";
        dimmerOpacity = 0.35;
        showScreenCorners = true;
        forceBlackScreenCorners = true;
        scaleRatio = 1;
        radiusRatio = 0.35;
        iRadiusRatio = 1;
        boxRadiusRatio = 1;
        screenRadiusRatio = 0.35;
        animationSpeed = 2;
        animationDisabled = false;

        compactLockScreen = true;
        lockOnSuspend = true;
        showSessionButtonsOnLockScreen = true;
        showHibernateOnLockScreen = false;

        enableShadows = false;
        shadowDirection = "center";
        shadowOffsetX = 0;
        shadowOffsetY = 0;

        language = "";
        allowPanelsOnScreenWithoutBar = true;
        showChangelogOnStartup = true;
        enableLockScreenCountdown = false;
        lockScreenCountdownDuration = 0;
        telemetryEnabled = false;
      };

      ui = {
        fontDefault = "JetBrainsMono NFP";
        fontFixed = "JetBrainsMono NFP";
        fontDefaultScale = 1.0;
        fontFixedScale = 1.0;
        tooltipsEnabled = true;
        panelBackgroundOpacity = 1.0;
        panelsAttachedToBar = false;
        settingsPanelMode = "centered";
        wifiDetailsViewMode = "grid";
        bluetoothDetailsViewMode = "grid";
        networkPanelView = "wifi";
        bluetoothHideUnnamedDevices = false;
        boxBorderEnabled = true;
      };

      templates = {
        activeTemplates = [
          {
            enabled = true;
            id = "qt";
          }
          {
            enabled = true;
            id = "ghostty";
          }
        ];
        enableUserTheming = false;
      };

      colorSchemes = {
        darkMode = true;
        useWallpaperColors = true;
        generationMethod = "rainbow";
        predefinedScheme = "Rose Pine";
        schedulingMode = "off";
      };

      location = {
        name = "Delhi, IN";
        weatherEnabled = false;
        weatherShowEffects = true;
        useFahrenheit = false;
        use12hourFormat = false;
        hideWeatherTimezone = false;
        hideWeatherCityName = false;

        firstDayOfWeek = -1;
        showWeekNumberInCalendar = false;
        showCalendarEvents = true;
        showCalendarWeather = false;
        analogClockInCalendar = false;
      };

      wallpaper = {
        enabled = true;
        overviewEnabled = false;

        directory = config.optx.wallpapers.paths.collection;
        enableMultiMonitorDirectories = false;
        setWallpaperOnAllMonitors = true;
        showHiddenFiles = false;
        monitorDirectories = [ ];
        panelPosition = "center";
        viewMode = "recursive";
        hideWallpaperFilenames = true;
        fillMode = "crop";
        fillColor = "#000000";

        automationEnabled = true;
        wallpaperChangeMode = "random";
        randomIntervalSec = 300;
        transitionType = "disc";
        transitionDuration = 500;
        transitionEdgeSmoothness = 0.1;

        useSolidColor = false;
        solidColor = "#000000";

        useWallhaven = false;
      };

      bar = {
        position = "top";
        monitors = [ ];
        density = "default";
        showOutline = false;
        showCapsule = false;
        capsuleOpacity = 0;
        backgroundOpacity = 0.9;
        useSeparateOpacity = true;
        floating = true;
        marginVertical = 4;
        marginHorizontal = 4;
        outerCorners = true;
        exclusive = true;
        hideOnOverview = true;
        widgets = {
          left = [
            {
              id = "Workspace";
              characterCount = 1;
              enableScrollWheel = false;
              followFocusedScreen = false;
              colorizeIcons = false;
              groupedBorderOpacity = 1;
              hideUnoccupied = false;
              iconScale = 0.8;
              labelMode = "none";
              showApplications = false;
              showLabelsOnlyWhenOccupied = false;
              unfocusedIconsOpacity = 1;
            }
            {
              id = "ActiveWindow";
              showIcon = true;
              useFixedWidth = false;
              maxWidth = 800;
              hideMode = "transparent";
              scrollingMode = "hover";
              colorizeIcons = false;
            }
          ];

          center = [ ];

          right = [
            {
              id = "MediaMini";
              compactMode = true;
              compactShowAlbumArt = true;
              compactShowVisualizer = false;
              hideMode = "idle";
              hideWhenIdle = true;
              maxWidth = 300;
              panelShowAlbumArt = true;
              panelShowVisualizer = false;
              scrollingMode = "hover";
              showAlbumArt = false;
              showArtistFirst = true;
              showProgressRing = true;
              showVisualizer = false;
              useFixedWidth = false;
              visualizerType = "linear";
            }
            {
              id = "Tray";
              drawerEnabled = true;
              colorizeIcons = false;
              hidePassive = false;
              pinned = [ ];
              blacklist = [ ];
            }
            {
              id = "Volume";
              displayMode = "alwaysHide";
              middleClickCommand = "pwvucontrol || pavucontrol";
            }
            {
              id = "Network";
              displayMode = "alwaysHide";
            }
            {
              id = "Battery";
              displayMode = "alwaysHide";
              hideIfIdle = false;
              hideIfNotDetected = false;
              showNoctaliaPerformance = true;
              showPowerProfiles = true;
              warningThreshold = 40;
            }
            {
              id = "NotificationHistory";
              showUnreadBadge = true;
              hideWhenZero = true;
              hideWhenZeroUnread = true;
            }
            {
              id = "Clock";
              formatHorizontal = "HH:mm ddd, MMM dd";
              formatVertical = "HH mm - dd MM";
              tooltipFormat = "HH:mm ddd, MMM dd";
              usePrimaryColor = false;
              useCustomFont = false;
              customFont = "";
            }
            {
              id = "ControlCenter";
              icon = "menu";
              useDistroLogo = true;
              colorizeDistroLogo = false;
              colorizeSystemIcon = "none";
              enableColorization = false;
              customIconPath = "";
            }
          ];
        };

        screenOverrides = [ ];
      };

      dock = {
        enabled = true;
        position = "bottom";
        displayMode = "auto_hide";
        backgroundOpacity = 0.9;
        floatingRatio = 0.35;
        size = 1.35;
        onlySameOutput = true;
        monitors = [ ];
        pinnedApps = [ ];
        colorizeIcons = false;
        pinnedStatic = false;
        inactiveIndicators = false;
        deadOpacity = 0.6;
        animationSpeed = 2;
      };
    };
  };
}
