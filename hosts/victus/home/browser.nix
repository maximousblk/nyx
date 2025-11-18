{ pkgs, inputs, ... }:
{
  imports = [ inputs.zen-browser.homeModules.default ];
  config = {
    programs.zen-browser = {
      enable = true;
      nativeMessagingHosts = [ pkgs.firefoxpwa ];

      policies = {
        # https://mozilla.github.io/policy-templates/
        AppAutoUpdate = false;
        DisableAppUpdate = true;
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        BackgroundAppUpdate = false;
        Bookmarks = [
          {
            Title = "Example";
            URL = "https://example.com";
            Favicon = "https://example.com/favicon.ico";
            Placement = "menu";
            Folder = "FolderName";
          }
        ];
        Containers.Default = [
          {
            name = "My container";
            icon = "pet";
            color = "turquoise";
          }
        ];
        ContentAnalysis.Enabled = false;
        DefaultDownloadDirectory = "~/Downloads";
        DisableFeedbackCommands = true;
        DisableFirefoxAccounts = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableProfileImport = true;
        DisableSetDesktopBackground = true;
        DisableTelemetry = true;
        DisplayBookmarksToolbar = "newtab";
        DontCheckDefaultBrowser = true;
        DownloadDirectory = "~/Downloads";
        EnableTrackingProtection.Value = true;
        EnableTrackingProtection.Locked = true;
        EnableTrackingProtection.Cryptomining = true;
        EnableTrackingProtection.Fingerprinting = true;
        EncryptedMediaExtensions.Enabled = true;

        FirefoxHome.Search = false;
        FirefoxHome.TopSites = false;
        FirefoxHome.SponsoredTopSites = false;
        FirefoxHome.Highlights = false;
        FirefoxHome.Pocket = false;
        FirefoxHome.SponsoredPocket = false;
        FirefoxHome.Snippets = false;
        FirefoxHome.Locked = true;

        GenerativeAI.Enabled = false;
        GenerativeAI.Chatbot = false;
        GenerativeAI.LinkPreviews = false;
        GenerativeAI.TabGroups = false;
        GenerativeAI.Locked = true;

        HardwareAcceleration = true;
        ManualAppUpdateOnly = true;
        NewTabPage = false;
        NoDefaultBookmarks = true;

        OfferToSaveLogins = false;
        OfferToSaveLoginsDefault = false;
        PasswordManagerEnabled = false;
        SkipTermsOfUse = true;

        UserMessaging.ExtensionRecommendations = false;
        UserMessaging.FeatureRecommendations = false;
        UserMessaging.UrlbarInterventions = false;
        UserMessaging.SkipOnboarding = false;
        UserMessaging.MoreFromMozilla = false;
        UserMessaging.FirefoxLabs = false;
        UserMessaging.Locked = false;
      };

      profiles.default = rec {
        isDefault = true;

        containersForce = true;
        containers = {
          main = {
            id = 1;
            color = "purple";
            icon = "tree";
          };
          personal = {
            id = 2;
            color = "green";
            icon = "fingerprint";
          };
          work = {
            id = 3;
            color = "blue";
            icon = "briefcase";
          };
          shenanigans = {
            id = 4;
            color = "red";
            icon = "chill";
          };
        };

        spaces = {
          "Main" = {
            id = "08e786ef-dd16-4420-8fa0-0becc6007b30";
            position = 1000;
            icon = "🏠";
            container = containers.main.id;
          };
          "Personal" = {
            id = "3a87cc3e-fd85-43f7-918c-412b283b855d";
            position = 2000;
            icon = "👤";
            container = containers.personal.id;
          };
          "Work" = {
            id = "5b1d98dd-ec10-417f-9390-170c30b8721b";
            position = 3000;
            icon = "💼";
            container = containers.work.id;
          };
          "Shenanigans" = {
            id = "869b97b6-b88c-4314-9c81-66360be63c0b";
            position = 4000;
            icon = "🦆";
            container = containers.shenanigans.id;
          };
        };

        pins = {
          "Mail" = {
            id = "860173a4-c319-4535-96e5-66b33db6bbf6";
            url = "https://mail.google.com/mail/u/0/#inbox";
            container = containers.main.id;
            workspace = spaces.Main.id;
            isEssential = true;
          };
        };

        settings = {
          "browser.tabs.inTitlebar" = 0;
          "browser.tabs.warnOnClose" = true;
          "browser.toolbars.bookmarks.visibility" = "newtab";
          "browser.search.separatePrivateDefault" = false;
          "browser.aboutConfig.showWarning" = false;
          "browser.shell.checkDefaultBrowser" = false;
          "extensions.pictureinpicture.enable_picture_in_picture_overrides" = true;
          "sidebar.visibility" = "hide-sidebar";

          "zen.view.compact.enable-at-startup" = true;
          "zen.view.compact.hide-toolbar" = true;
          "zen.view.use-single-toolbar" = false;
          "zen.welcome-screen.seen" = true;
        };
      };
    };
  };
}
