{
  config,
  lib,
  modx,
  pkgs,
  ...
}:
let
  persist = "/var/lib/signoz";
  clickhouse_data = "${persist}/clickhouse";
  zookeeper_data = "${persist}/zookeeper";
  sqlite_data = "${persist}/sqlite";
  user_scripts = "${persist}/user_scripts";

  xml = pkgs.formats.xml { };
  yaml = pkgs.formats.yaml { };

  # Version tags
  clickhouseVersion = "25.5.6";
  signozVersion = "v0.122.0";
  otelcolVersion = "v0.144.3";
  zookeeperVersion = "3.7.1";

  clickhouseConfig = xml.generate "clickhouse-config.xml" {
    clickhouse = {
      logger = {
        level = "information";
        formatting.type = "json";
        log = "/var/log/clickhouse-server/clickhouse-server.log";
        errorlog = "/var/log/clickhouse-server/clickhouse-server.err.log";
        size = "100M";
        count = 3;
      };

      http_port = 8123;
      tcp_port = 9000;
      mysql_port = 9004;
      postgresql_port = 9005;
      interserver_http_port = 9009;

      listen_host = "0.0.0.0";
      max_connections = 4096;
      keep_alive_timeout = 3;
      max_concurrent_queries = 100;

      path = "/var/lib/clickhouse/";
      tmp_path = "/var/lib/clickhouse/tmp/";
      user_files_path = "/var/lib/clickhouse/user_files/";
      user_scripts_path = "/var/lib/clickhouse/user_scripts/";
      format_schema_path = "/var/lib/clickhouse/format_schemas/";

      user_directories = {
        users_xml.path = "users.xml";
        local_directory.path = "/var/lib/clickhouse/access/";
      };

      default_profile = "default";
      default_database = "default";
      mlock_executable = true;

      macros = {
        shard = "01";
        replica = "signoz-01-1";
      };

      prometheus = {
        endpoint = "/metrics";
        port = 9363;
        metrics = true;
        events = true;
        asynchronous_metrics = true;
        status_info = true;
      };

      distributed_ddl.path = "/clickhouse/task_queue/ddl";

      query_log = {
        database = "system";
        table = "query_log";
        partition_by = "toYYYYMM(event_date)";
        flush_interval_milliseconds = 7500;
      };

      metric_log = {
        database = "system";
        table = "metric_log";
        flush_interval_milliseconds = 7500;
        collect_interval_milliseconds = 1000;
      };

      opentelemetry_span_log = {
        engine = "engine MergeTree partition by toYYYYMM(finish_date) order by (finish_date, finish_time_us, trace_id)";
        database = "system";
        table = "opentelemetry_span_log";
        flush_interval_milliseconds = 7500;
      };
    };
  };

  clickhouseUsers = xml.generate "clickhouse-users.xml" {
    clickhouse = {
      profiles = {
        default = {
          max_memory_usage = 10000000000;
          load_balancing = "random";
        };
        readonly.readonly = 1;
      };

      users.default = {
        password = "";
        networks.ip = "::/0";
        profile = "default";
        quota = "default";
      };

      quotas.default.interval = {
        duration = 3600;
        queries = 0;
        errors = 0;
        result_rows = 0;
        read_rows = 0;
        execution_time = 0;
      };
    };
  };

  clickhouseCluster = xml.generate "clickhouse-cluster.xml" {
    clickhouse = {
      zookeeper.node = {
        "@index" = 1;
        host = "signoz-zookeeper";
        port = 2181;
      };

      remote_servers.cluster.shard.replica = {
        host = "signoz-clickhouse";
        port = 9000;
      };
    };
  };

  clickhouseCustomFunction = xml.generate "clickhouse-custom-function.xml" {
    functions.function = {
      type = "executable";
      name = "histogramQuantile";
      return_type = "Float64";
      argument = [
        {
          type = "Array(Float64)";
          name = "buckets";
        }
        {
          type = "Array(Float64)";
          name = "counts";
        }
        {
          type = "Float64";
          name = "quantile";
        }
      ];
      format = "CSV";
      command = "./histogramQuantile";
    };
  };

  otelCollectorConfig = yaml.generate "otel-collector-config.yaml" {
    connectors.signozmeter = {
      metrics_flush_interval = "1h";
      dimensions = [
        { name = "service.name"; }
        { name = "deployment.environment"; }
        { name = "host.name"; }
      ];
    };

    receivers = {
      otlp.protocols = {
        grpc.endpoint = "0.0.0.0:4317";
        http.endpoint = "0.0.0.0:4318";
      };

      prometheus.config = {
        global.scrape_interval = "60s";
        scrape_configs = [
          {
            job_name = "otel-collector";
            static_configs = [
              {
                targets = [ "localhost:8888" ];
                labels.job_name = "otel-collector";
              }
            ];
          }
        ];
      };

      docker_stats = {
        endpoint = "unix:///var/run/docker.sock";
        api_version = "1.40";
        metrics = {
          "container.cpu.utilization".enabled = true;
          "container.memory.percent".enabled = true;
          "container.network.io.usage.rx_bytes".enabled = true;
          "container.network.io.usage.tx_bytes".enabled = true;
          "container.network.io.usage.rx_dropped".enabled = true;
          "container.network.io.usage.tx_dropped".enabled = true;
          "container.memory.usage.limit".enabled = true;
          "container.memory.usage.total".enabled = true;
          "container.blockio.io_service_bytes_recursive".enabled = true;
        };
      };
    };

    processors = {
      batch = {
        send_batch_size = 10000;
        send_batch_max_size = 11000;
        timeout = "10s";
      };
      "batch/meter" = {
        send_batch_max_size = 25000;
        send_batch_size = 20000;
        timeout = "1s";
      };
      resourcedetection = {
        detectors = [
          "env"
          "system"
        ];
        timeout = "2s";
      };
      "resourcedetection/docker" = {
        detectors = [
          "env"
          "docker"
        ];
        timeout = "2s";
        override = false;
      };
      "signozspanmetrics/delta" = {
        metrics_exporter = "signozclickhousemetrics";
        metrics_flush_interval = "60s";
        latency_histogram_buckets = [
          "100us"
          "1ms"
          "2ms"
          "6ms"
          "10ms"
          "50ms"
          "100ms"
          "250ms"
          "500ms"
          "1000ms"
          "1400ms"
          "2000ms"
          "5s"
          "10s"
          "20s"
          "40s"
          "60s"
        ];
        dimensions_cache_size = 100000;
        aggregation_temporality = "AGGREGATION_TEMPORALITY_DELTA";
        enable_exp_histogram = true;
        dimensions = [
          {
            name = "service.namespace";
            default = "default";
          }
          {
            name = "deployment.environment";
            default = "default";
          }
          { name = "signoz.collector.id"; }
          { name = "service.version"; }
          { name = "browser.platform"; }
          { name = "browser.mobile"; }
          { name = "k8s.cluster.name"; }
          { name = "k8s.node.name"; }
          { name = "k8s.namespace.name"; }
          { name = "host.name"; }
          { name = "host.type"; }
          { name = "container.name"; }
        ];
      };
    };

    extensions = {
      health_check.endpoint = "0.0.0.0:13133";
      pprof.endpoint = "0.0.0.0:1777";
    };

    exporters = {
      clickhousetraces = {
        datasource = "tcp://signoz-clickhouse:9000/signoz_traces";
        low_cardinal_exception_grouping = "\${env:LOW_CARDINAL_EXCEPTION_GROUPING}";
        use_new_schema = true;
      };
      signozclickhousemetrics.dsn = "tcp://signoz-clickhouse:9000/signoz_metrics";
      clickhouselogsexporter = {
        dsn = "tcp://signoz-clickhouse:9000/signoz_logs";
        timeout = "10s";
        use_new_schema = true;
      };
      signozclickhousemeter = {
        dsn = "tcp://signoz-clickhouse:9000/signoz_meter";
        timeout = "45s";
        sending_queue.enabled = false;
      };
      metadataexporter = {
        cache.provider = "in_memory";
        dsn = "tcp://signoz-clickhouse:9000/signoz_metadata";
        enabled = true;
        timeout = "45s";
      };
    };

    service = {
      telemetry.logs.encoding = "json";
      extensions = [
        "health_check"
        "pprof"
      ];
      pipelines = {
        traces = {
          receivers = [ "otlp" ];
          processors = [
            "signozspanmetrics/delta"
            "batch"
          ];
          exporters = [
            "clickhousetraces"
            "metadataexporter"
            "signozmeter"
          ];
        };
        metrics = {
          receivers = [
            "otlp"
            "docker_stats"
          ];
          processors = [
            "batch"
            "resourcedetection/docker"
          ];
          exporters = [
            "signozclickhousemetrics"
            "metadataexporter"
            "signozmeter"
          ];
        };
        "metrics/prometheus" = {
          receivers = [ "prometheus" ];
          processors = [ "batch" ];
          exporters = [
            "signozclickhousemetrics"
            "metadataexporter"
            "signozmeter"
          ];
        };
        logs = {
          receivers = [ "otlp" ];
          processors = [ "batch" ];
          exporters = [
            "clickhouselogsexporter"
            "metadataexporter"
            "signozmeter"
          ];
        };
        "metrics/meter" = {
          receivers = [ "signozmeter" ];
          processors = [ "batch/meter" ];
          exporters = [ "signozclickhousemeter" ];
        };
      };
    };
  };

  otelOpampConfig = yaml.generate "otel-collector-opamp-config.yaml" { server_endpoint = "ws://signoz:4320/v1/opamp"; };
in
{
  imports = [ modx.nixos.tailscale-services ];

  topology.self.services.signoz = {
    name = "SigNoz";
    info = "Observability platform";
    icon = builtins.fetchurl {
      url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/signoz.svg";
      sha256 = "1k60vdiwd8gifag1rfany9bkrip73q3a76rcx4dpyz8qx7ry3m3a";
    };
  };

  virtualisation.quadlet.enable = false;

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      # --- INIT: Download histogram binary ---
      signoz-init-clickhouse = {
        serviceName = "signoz-init-clickhouse";
        image = "docker.io/clickhouse/clickhouse-server:${clickhouseVersion}";
        pull = "always";
        networks = [ "scry" ];
        volumes = [ "${user_scripts}:/var/lib/clickhouse/user_scripts" ];
        entrypoint = "bash";
        cmd = [
          "-c"
          (lib.concatStringsSep " && " [
            ''version="v0.0.1"''
            "node_os=$(uname -s | tr '[:upper:]' '[:lower:]')"
            "node_arch=$(uname -m | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)"
            ''echo "Fetching histogram-binary for $node_os/$node_arch"''
            "cd /tmp"
            ''wget -O histogram-quantile.tar.gz "https://github.com/SigNoz/signoz/releases/download/histogram-quantile%2F$version/histogram-quantile_''${node_os}_''${node_arch}.tar.gz"''
            "tar -xvzf histogram-quantile.tar.gz"
            "mv histogram-quantile /var/lib/clickhouse/user_scripts/histogramQuantile"
          ])
        ];
      };

      # --- ZOOKEEPER ---
      signoz-zookeeper = {
        serviceName = "signoz-zookeeper";
        image = "docker.io/signoz/zookeeper:${zookeeperVersion}";
        pull = "always";
        user = "root";
        networks = [ "scry" ];
        volumes = [ "${zookeeper_data}:/bitnami/zookeeper" ];
        environment = {
          ZOO_SERVER_ID = "1";
          ALLOW_ANONYMOUS_LOGIN = "yes";
          ZOO_AUTOPURGE_INTERVAL = "1";
          ZOO_ENABLE_PROMETHEUS_METRICS = "yes";
          ZOO_PROMETHEUS_METRICS_PORT_NUMBER = "9141";
        };
        extraOptions = [
          "--health-cmd=curl -s -m 2 http://localhost:8080/commands/ruok | grep error | grep null"
          "--health-interval=30s"
          "--health-timeout=5s"
          "--health-retries=3"
        ];
      };

      # --- CLICKHOUSE ---
      signoz-clickhouse = {
        serviceName = "signoz-clickhouse";
        image = "docker.io/clickhouse/clickhouse-server:${clickhouseVersion}";
        pull = "always";
        dependsOn = [
          "signoz-init-clickhouse"
          "signoz-zookeeper"
        ];
        networks = [ "scry" ];
        volumes = [
          "${clickhouse_data}:/var/lib/clickhouse"
          "${user_scripts}:/var/lib/clickhouse/user_scripts"
          "${clickhouseConfig}:/etc/clickhouse-server/config.xml:ro"
          "${clickhouseUsers}:/etc/clickhouse-server/users.xml:ro"
          "${clickhouseCluster}:/etc/clickhouse-server/config.d/cluster.xml:ro"
          "${clickhouseCustomFunction}:/etc/clickhouse-server/custom-function.xml:ro"
        ];
        environment.CLICKHOUSE_SKIP_USER_SETUP = "1";
        extraOptions = [
          "--health-cmd=wget --spider -q 0.0.0.0:8123/ping"
          "--health-interval=30s"
          "--health-timeout=5s"
          "--health-retries=3"
          "--ulimit=nproc=65535"
          "--ulimit=nofile=262144:262144"
        ];
      };

      # --- TELEMETRYSTORE MIGRATOR ---
      signoz-telemetrystore-migrator = {
        serviceName = "signoz-telemetrystore-migrator";
        image = "docker.io/signoz/signoz-otel-collector:${otelcolVersion}";
        pull = "always";
        dependsOn = [ "signoz-clickhouse" ];
        networks = [ "scry" ];
        entrypoint = "/bin/sh";
        cmd = [
          "-c"
          (lib.concatStringsSep " && " [
            "/signoz-otel-collector migrate bootstrap"
            "/signoz-otel-collector migrate sync up"
            "/signoz-otel-collector migrate async up"
          ])
        ];
        environment = {
          SIGNOZ_OTEL_COLLECTOR_CLICKHOUSE_DSN = "tcp://signoz-clickhouse:9000";
          SIGNOZ_OTEL_COLLECTOR_CLICKHOUSE_CLUSTER = "cluster";
          SIGNOZ_OTEL_COLLECTOR_CLICKHOUSE_REPLICATION = "true";
          SIGNOZ_OTEL_COLLECTOR_TIMEOUT = "10m";
        };
      };

      # --- SIGNOZ (Query Service + UI) ---
      signoz = {
        serviceName = "signoz";
        image = "docker.io/signoz/signoz:${signozVersion}";
        pull = "always";
        dependsOn = [
          "signoz-clickhouse"
          "signoz-telemetrystore-migrator"
        ];
        ports = [ "127.0.0.1:8080:8080" ];
        networks = [ "scry" ];
        volumes = [ "${sqlite_data}:/var/lib/signoz" ];
        environment = {
          SIGNOZ_ALERTMANAGER_PROVIDER = "signoz";
          SIGNOZ_TELEMETRYSTORE_CLICKHOUSE_DSN = "tcp://signoz-clickhouse:9000";
          SIGNOZ_SQLSTORE_SQLITE_PATH = "/var/lib/signoz/signoz.db";
          STORAGE = "clickhouse";
          GODEBUG = "netdns=go";
          TELEMETRY_ENABLED = "false";
          SIGNOZ_ANALYTICS_ENABLED = "false";
          DEPLOYMENT_TYPE = "docker-standalone";
          DOT_METRICS_ENABLED = "true";
        };
        extraOptions = [
          "--health-cmd=wget --spider -q localhost:8080/api/v1/health"
          "--health-interval=30s"
          "--health-timeout=5s"
          "--health-retries=3"
        ];
      };

      # --- OTEL COLLECTOR (SigNoz internal) ---
      signoz-otel-collector = {
        serviceName = "signoz-otel-collector";
        image = "docker.io/signoz/signoz-otel-collector:${otelcolVersion}";
        pull = "always";
        user = "root";
        dependsOn = [ "signoz" ];
        ports = [
          "127.0.0.1:4317:4317"
          "127.0.0.1:4318:4318"
        ];
        networks = [ "scry" ];
        volumes = [
          "${otelCollectorConfig}:/etc/otel-collector-config.yaml:ro"
          "${otelOpampConfig}:/etc/manager-config.yaml:ro"
          "/var/run/docker.sock:/var/run/docker.sock:ro"
        ];
        entrypoint = "/bin/sh";
        cmd = [
          "-c"
          (lib.concatStringsSep " && " [
            "/signoz-otel-collector migrate sync check"
            "/signoz-otel-collector --config=/etc/otel-collector-config.yaml --manager-config=/etc/manager-config.yaml --copy-path=/var/tmp/collector-config.yaml"
          ])
        ];
        environment = {
          OTEL_RESOURCE_ATTRIBUTES = "host.name=signoz-host,os.type=linux";
          LOW_CARDINAL_EXCEPTION_GROUPING = "false";
          SIGNOZ_OTEL_COLLECTOR_CLICKHOUSE_DSN = "tcp://signoz-clickhouse:9000";
          SIGNOZ_OTEL_COLLECTOR_CLICKHOUSE_CLUSTER = "cluster";
          SIGNOZ_OTEL_COLLECTOR_CLICKHOUSE_REPLICATION = "true";
          SIGNOZ_OTEL_COLLECTOR_TIMEOUT = "10m";
        };
      };
    };
  };

  systemd.services =
    let
      docker = "${config.virtualisation.docker.package}/bin/docker";
      scryNetworkContainers = [
        "signoz-init-clickhouse"
        "signoz-zookeeper"
        "signoz-clickhouse"
        "signoz-telemetrystore-migrator"
        "signoz"
        "signoz-otel-collector"
      ];
    in
    {
      docker-network-scry = {
        description = "Create Docker network: scry";
        after = [ "docker.service" ];
        requires = [ "docker.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.writeShellScript "docker-network-scry" ''
            ${docker} network inspect scry >/dev/null 2>&1 || ${docker} network create scry
          ''}";
        };
      };
    }
    // lib.genAttrs scryNetworkContainers (_: {
      after = [ "docker-network-scry.service" ];
      requires = [ "docker-network-scry.service" ];
    });

  # Create data directories
  systemd.tmpfiles.settings."10-signoz" = {
    "${clickhouse_data}".d = {
      mode = "0755";
      user = "root";
      group = "root";
    };
    "${zookeeper_data}".d = {
      mode = "0755";
      user = "root";
      group = "root";
    };
    "${sqlite_data}".d = {
      mode = "0755";
      user = "root";
      group = "root";
    };
    "${user_scripts}".d = {
      mode = "0755";
      user = "root";
      group = "root";
    };
  };

  # Expose SigNoz UI and OTLP ingest over Tailscale only.
  optx.tailscale.services = {
    signoz = {
      serve."https:443" = "http://localhost:8080";
      backends = [ "signoz.service" ];
    };

    otlp = {
      serve = {
        "https:443" = "http://localhost:4318";
        "tcp:4317" = "localhost:4317";
        "tcp:4318" = "localhost:4318";
      };
      backends = [ "signoz-otel-collector.service" ];
    };
  };
}
