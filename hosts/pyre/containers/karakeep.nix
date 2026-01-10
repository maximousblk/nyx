{
  config,
  common,
  modx,
  ...
}:
let
  persist = "${common.paths.data}/karakeep";
  data_meilisearch = "${persist}/meili";
  data_karakeep = "${persist}/data";

  net = config.virtualisation.quadlet.networks.karakeep;
  mainNet = config.virtualisation.quadlet.networks.main;
  chrome = config.virtualisation.quadlet.containers.karakeep-chrome;
  meili = config.virtualisation.quadlet.containers.karakeep-meilisearch;

  nextauthSecretEnv = config.age.secrets.karakeep-env-nextauth-secret.path;
  meiliMasterKeyEnv = config.age.secrets.karakeep-env-meili-master-key.path;
in
{
  imports = [ modx.nixos.tailscale-services ];
  # NEXTAUTH_SECRET - used by karakeep only
  age.secrets.karakeep-env-nextauth-secret = {
    mode = "0400";
    generator.script =
      { pkgs, ... }:
      ''
        echo -n "NEXTAUTH_SECRET="
        ${pkgs.pwgen}/bin/pwgen -s 48 1
      '';
  };

  # MEILI_MASTER_KEY - used by both meilisearch and karakeep
  age.secrets.karakeep-env-meili-master-key = {
    mode = "0400";
    generator.script =
      { pkgs, ... }:
      ''
        echo -n "MEILI_MASTER_KEY="
        ${pkgs.pwgen}/bin/pwgen -s 48 1
      '';
  };

  topology.self.services.karakeep = {
    name = "Karakeep";
    info = "Bookmark manager";
    icon = builtins.fetchurl {
      url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/karakeep-light.svg";
      sha256 = "06mic8gs6ca36rkwh20sq3ykw5dlqj2nsz760j78pfg5g2krhrrg";
    };
  };

  systemd.tmpfiles.settings."10-karakeep" = {
    "${data_meilisearch}".d = {
      mode = "0755";
      user = "1000";
      group = "100";
    };
    "${data_karakeep}".d = {
      mode = "0755";
      user = "1000";
      group = "100";
    };
  };

  virtualisation.quadlet = {

    networks.karakeep = {
      networkConfig = {
        subnets = [ "10.69.1.0/24" ];
        driver = "bridge";
      };
    };

    containers = {

      # --- CHROME ---
      karakeep-chrome = {
        autoStart = true;
        containerConfig = {
          image = "gcr.io/zenika-hub/alpine-chrome:124";
          pull = "always";

          exec = [
            "--no-sandbox"
            "--disable-gpu"
            "--disable-dev-shm-usage"
            "--remote-debugging-address=0.0.0.0"
            "--remote-debugging-port=9222"
            "--hide-scrollbars"
          ];

          networks = [ net.ref ];
          networkAliases = [ "karakeep-chrome" ];
        };

        serviceConfig.Restart = "always";
      };

      # --- MEILISEARCH ---
      karakeep-meilisearch = {
        autoStart = true;
        containerConfig = {
          image = "getmeili/meilisearch:v1.13.3";
          pull = "always";

          networks = [ net.ref ];
          networkAliases = [ "karakeep-meilisearch" ];

          volumes = [ "${data_meilisearch}:/meili_data" ];

          environmentFiles = [ meiliMasterKeyEnv ];
          environments = common.env // {
            MEILI_NO_ANALYTICS = "true";
            MEILI_ADDR = "http://0.0.0.0:7700";
          };
        };

        serviceConfig.Restart = "always";
        unitConfig.RequiresMountsFor = data_meilisearch;
      };

      # --- KARAKEEP APP ---
      karakeep = {
        autoStart = true;
        containerConfig = {
          image = "ghcr.io/karakeep-app/karakeep:release";
          pull = "always";
          publishPorts = [ "127.0.0.1:3000:3000" ];

          networks = [
            net.ref
            mainNet.ref
          ];
          networkAliases = [ "karakeep" ];
          volumes = [ "${data_karakeep}:/data" ];

          environmentFiles = [
            nextauthSecretEnv
            meiliMasterKeyEnv
          ];
          environments = common.env // {
            DATA_DIR = "/data";
            MEILI_ADDR = "http://karakeep-meilisearch:7700";
            BROWSER_WEB_URL = "http://karakeep-chrome:9222";
            NEXTAUTH_URL = "https://karakeep.pony-clownfish.ts.net";

            # Disable AI tagging explicitly
            INFERENCE_ENABLE_AUTO_TAGGING = "false";

            # Aggressive archival options
            CRAWLER_FULL_PAGE_ARCHIVE = "true";
            CRAWLER_FULL_PAGE_SCREENSHOT = "true";
            CRAWLER_VIDEO_DOWNLOAD = "true";
            CRAWLER_VIDEO_DOWNLOAD_MAX_SIZE = "-1";

            # OCR languages
            OCR_LANGS = "eng,hin,jpn,chi_sim,chi_tra,rus";

            # Performance & security
            DB_WAL_MODE = "true";
            DISABLE_SIGNUPS = "true";
            LOG_LEVEL = "info";

            # OpenTelemetry - send traces to SigNoz
            OTEL_TRACING_ENABLED = "true";
            OTEL_EXPORTER_OTLP_ENDPOINT = "http://signoz-otel-collector:4318/v1/traces";
            OTEL_SERVICE_NAME = "karakeep";
          };
        };

        serviceConfig.Restart = "always";

        unitConfig = {
          After = [
            chrome.ref
            meili.ref
          ];
          Requires = [
            chrome.ref
            meili.ref
          ];
          RequiresMountsFor = data_karakeep;
        };
      };
    };
  };

  # Expose karakeep via Tailscale Services
  optx.tailscale.services.karakeep = {
    target = "http://localhost:3000";
    port = 443;
    protocol = "https";
    unitConfig = {
      After = [ "karakeep.service" ];
      BindsTo = [ "karakeep.service" ];
    };
    installConfig = {
      WantedBy = [ "karakeep.service" ];
    };
  };
}
