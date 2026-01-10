{
  config,
  common,
  modx,
  ...
}:
let
  persist = "${common.paths.data}/immich";
  library_dir = "${persist}/library";
  postgres_dir = "${persist}/postgres";
  model_cache_dir = "${persist}/model-cache";

  # External library for importing existing photos (read-only)
  # external_library_dir = "/mnt/data/photos";

  net = config.virtualisation.quadlet.networks.immich;
  mainNet = config.virtualisation.quadlet.networks.main;
  valkey = config.virtualisation.quadlet.containers.immich-valkey;
  postgres = config.virtualisation.quadlet.containers.immich-postgres;
  ml = config.virtualisation.quadlet.containers.immich-ml;

  dbPasswordEnv = config.age.secrets.immich-env-db-password.path;
in
{
  imports = [ modx.nixos.tailscale-services ];

  # DB_PASSWORD - PostgreSQL password for Immich (manually managed)
  age.secrets.immich-env-db-password.mode = "0400";

  topology.self.services.immich = {
    name = "Immich";
    info = "Photo & video management";
    icon = "services.immich";
  };

  systemd.tmpfiles.settings."10-immich" = {
    "${library_dir}".d = {
      mode = "0755";
      user = "1000";
      group = "100";
    };
    "${postgres_dir}".d = {
      mode = "0755";
      user = "999";
      group = "999";
    };
    "${model_cache_dir}".d = {
      mode = "0755";
      user = "1000";
      group = "100";
    };
  };

  virtualisation.quadlet = {

    networks.immich = {
      networkConfig = {
        subnets = [ "10.69.3.0/24" ];
        driver = "bridge";
      };
    };

    containers = {

      # --- VALKEY ---
      immich-valkey = {
        autoStart = true;
        containerConfig = {
          image = "docker.io/valkey/valkey:9";
          pull = "always";

          networks = [ net.ref ];
          networkAliases = [ "immich-valkey" ];

          healthCmd = "redis-cli ping || exit 1";
        };

        serviceConfig.Restart = "always";
      };

      # --- POSTGRES ---
      immich-postgres = {
        autoStart = true;
        containerConfig = {
          image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0";
          pull = "always";

          networks = [ net.ref ];
          networkAliases = [ "immich-postgres" ];

          volumes = [ "${postgres_dir}:/var/lib/postgresql/data" ];

          environmentFiles = [ dbPasswordEnv ];
          environments = {
            POSTGRES_USER = "postgres";
            POSTGRES_DB = "immich";
            POSTGRES_INITDB_ARGS = "--data-checksums";
          };

          # PostgreSQL requires larger shared memory
          podmanArgs = [ "--shm-size=128m" ];
        };

        serviceConfig.Restart = "always";
        unitConfig.RequiresMountsFor = postgres_dir;
      };

      # --- MACHINE LEARNING ---
      immich-ml = {
        autoStart = true;
        containerConfig = {
          image = "ghcr.io/immich-app/immich-machine-learning:v2-openvino";
          pull = "always";

          networks = [ net.ref ];
          networkAliases = [ "immich-ml" ];

          volumes = [
            "${model_cache_dir}:/cache"
            "/sys/class/drm:/sys/class/drm:ro"
            "/sys/dev/char:/sys/dev/char:ro"
          ];

          devices = [ "/dev/dri:/dev/dri" ];
          podmanArgs = [ "--device-cgroup-rule=c 189:* rmw" ];

          environments = common.env // {
            DEVICE = "openvino";
            OPENVINO_DEVICE = "GPU";
            OPENVINO_CACHE_DIR = "/cache/openvino";
          };
        };

        serviceConfig.Restart = "always";
        unitConfig.RequiresMountsFor = model_cache_dir;
      };

      # --- IMMICH SERVER ---
      immich = {
        autoStart = true;
        containerConfig = {
          image = "ghcr.io/immich-app/immich-server:v2";
          pull = "always";
          publishPorts = [ "127.0.0.1:2283:2283" ];

          networks = [
            net.ref
            mainNet.ref
          ];
          networkAliases = [ "immich" ];

          volumes = [
            "${library_dir}:/usr/src/app/upload"
            # External library for importing existing photos (read-only)
            # "${external_library_dir}:/mnt/external:ro"
          ];

          environmentFiles = [ dbPasswordEnv ];
          environments = common.env // {
            # Machine Learning
            IMMICH_MACHINE_LEARNING_URL = "http://immich-ml:3003";

            # Database
            DB_HOSTNAME = "immich-postgres";
            DB_USERNAME = "postgres";
            DB_DATABASE_NAME = "immich";

            # Redis/Valkey
            REDIS_HOSTNAME = "immich-valkey";
            REDIS_PORT = "6379";

            # Logging
            IMMICH_LOG_LEVEL = "log";

            # OpenTelemetry - send traces/metrics to SigNoz
            IMMICH_TELEMETRY_INCLUDE = "all";
            OTEL_EXPORTER_OTLP_ENDPOINT = "http://signoz-otel-collector:4318";
            OTEL_SERVICE_NAME = "immich";
          };
        };

        serviceConfig.Restart = "always";

        unitConfig = {
          After = [
            valkey.ref
            postgres.ref
            ml.ref
          ];
          Requires = [
            valkey.ref
            postgres.ref
            ml.ref
          ];
          RequiresMountsFor = library_dir;
        };
      };
    };
  };

  # Expose Immich via Tailscale Services
  optx.tailscale.services.immich = {
    target = "http://localhost:2283";
    port = 443;
    protocol = "https";
    unitConfig = {
      After = [ "immich.service" ];
      BindsTo = [ "immich.service" ];
    };
    installConfig = {
      WantedBy = [ "immich.service" ];
    };
  };
}
