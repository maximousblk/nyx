{
  config,
  common,
  modx,
  ...
}:
let
  persist = "${common.paths.data}/paperless";
  data_dir = "${persist}/data";
  media_dir = "${persist}/media";
  export_dir = "${persist}/export";

  net = config.virtualisation.quadlet.networks.paperless;
  valkey = config.virtualisation.quadlet.containers.paperless-valkey;
  tika = config.virtualisation.quadlet.containers.paperless-tika;
  gotenberg = config.virtualisation.quadlet.containers.paperless-gotenberg;

  secretKeyEnv = config.age.secrets.paperless-env-secret-key.path;
in
{
  imports = [ modx.nixos.tailscale-services ];

  # PAPERLESS_SECRET_KEY - session signing key
  age.secrets.paperless-env-secret-key = {
    mode = "0400";
    generator.script = { pkgs, ... }: ''
      echo -n "PAPERLESS_SECRET_KEY="
      ${pkgs.pwgen}/bin/pwgen -s 64 1
    '';
  };

  topology.self.services.paperless = {
    name = "Paperless-ngx";
    info = "Document management system";
    icon = "services.paperless-ngx";
  };

  optx.opentelemetry.agent = {
    extraReceivers."prometheus/paperless_flower" = {
      config.scrape_configs = [
        {
          job_name = "paperless-flower";
          scrape_interval = "15s";
          static_configs = [ { targets = [ "127.0.0.1:5555" ]; } ];
        }
      ];
    };
  };

  systemd.tmpfiles.settings."10-paperless" = {
    "${data_dir}".d = {
      mode = "0755";
      user = "1000";
      group = "100";
    };
    "${media_dir}".d = {
      mode = "0755";
      user = "1000";
      group = "100";
    };
    "${export_dir}".d = {
      mode = "0755";
      user = "1000";
      group = "100";
    };
  };

  virtualisation.quadlet = {

    networks.paperless = {
      networkConfig = {
        subnets = [ "10.69.2.0/24" ];
        driver = "bridge";
      };
    };

    containers = {

      # --- VALKEY ---
      paperless-valkey = {
        autoStart = true;
        containerConfig = {
          image = "docker.io/valkey/valkey:9";
          pull = "newer";

          networks = [ net.ref ];
          networkAliases = [ "paperless-valkey" ];
        };

        serviceConfig.Restart = "always";
      };

      # --- TIKA ---
      paperless-tika = {
        autoStart = true;
        containerConfig = {
          image = "docker.io/apache/tika:3.3.1.0-full";
          pull = "newer";

          networks = [ net.ref ];
          networkAliases = [ "paperless-tika" ];
        };

        serviceConfig.Restart = "always";
      };

      # --- GOTENBERG ---
      paperless-gotenberg = {
        autoStart = true;
        containerConfig = {
          image = "docker.io/gotenberg/gotenberg:8.25";
          pull = "newer";

          exec = [
            "gotenberg"
            "--chromium-disable-javascript=true"
            "--chromium-allow-list=file:///tmp/.*"
          ];

          networks = [ net.ref ];
          networkAliases = [ "paperless-gotenberg" ];
        };

        serviceConfig.Restart = "always";
      };

      # --- PAPERLESS-NGX ---
      paperless = {
        autoStart = true;
        containerConfig = {
          image = "ghcr.io/paperless-ngx/paperless-ngx:3.0";
          pull = "newer";
          publishPorts = [
            "127.0.0.1:8000:8000"
            "127.0.0.1:5555:5555"
          ];

          networks = [ net.ref ];
          networkAliases = [ "paperless" ];

          volumes = [
            "${data_dir}:/usr/src/paperless/data"
            "${media_dir}:/usr/src/paperless/media"
            "${export_dir}:/usr/src/paperless/export"
            # Consume directory - uncomment to enable folder watching
            # "${consume_dir}:/usr/src/paperless/consume"
          ];

          environmentFiles = [ secretKeyEnv ];
          environments = common.env // {
            # Redis
            PAPERLESS_REDIS = "redis://paperless-valkey:6379";

            # URL & access
            PAPERLESS_URL = "https://paperless.pony-clownfish.ts.net";
            PAPERLESS_ACCOUNT_ALLOW_SIGNUPS = "false";
            PAPERLESS_ENABLE_FLOWER = "1";

            # Timezone (override common.env TZ format)
            PAPERLESS_TIME_ZONE = "Asia/Kolkata";

            # Tika + Gotenberg for Office docs & email
            PAPERLESS_TIKA_ENABLED = "1";
            PAPERLESS_TIKA_ENDPOINT = "http://paperless-tika:9998";
            PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://paperless-gotenberg:3000";

            # OCR - English + Hindi
            PAPERLESS_OCR_LANGUAGE = "eng+hin";
            PAPERLESS_OCR_LANGUAGES = "hin"; # Additional languages to install (eng included by default)
          };
        };

        serviceConfig.Restart = "always";

        unitConfig = {
          After = [
            valkey.ref
            tika.ref
            gotenberg.ref
          ];
          Wants = [
            valkey.ref
            tika.ref
            gotenberg.ref
          ];
          PartOf = [
            valkey.ref
            tika.ref
            gotenberg.ref
          ];
          RequiresMountsFor = [
            data_dir
            media_dir
            export_dir
          ];
        };
      };
    };
  };

  # Expose paperless via Tailscale Services
  optx.tailscale.services.paperless = {
    serve."https:443" = "http://localhost:8000";
    backends = [ "paperless.service" ];
  };
}
