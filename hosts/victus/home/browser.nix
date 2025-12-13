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

        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          adnauseam
          bitwarden
          sponsorblock
          youtube-high-definition
        ];

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
          "browser.aboutConfig.showWarning" = false;
          "browser.search.separatePrivateDefault" = false;
          "browser.shell.checkDefaultBrowser" = false;
          "browser.tabs.inTitlebar" = 0;
          "browser.tabs.warnOnClose" = true;
          "browser.toolbars.bookmarks.visibility" = "never";

          "extensions.autoDisableScopes" = 0;
          "extensions.pictureinpicture.enable_picture_in_picture_overrides" = true;
          "extensions.update.autoUpdateDefault" = false;

          "privacy.exposeContentTitleInWindow.pbm" = false;

          "zen.view.compact.enable-at-startup" = true; # Enable compact mode
          "zen.view.compact.hide-tabbar" = true; # Hide Sidebar
          "zen.view.compact.hide-toolbar" = false; # Hide toolbar
          "zen.view.use-single-toolbar" = false; # Combine sidebar and toolbar
          "zen.welcome-screen.seen" = true;
        };
      };
    };
  };
}
