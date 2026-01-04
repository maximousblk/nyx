{
  config,
  lib,
  common,
  modx,
  ...
}:
let
  persist = "${common.paths.data}/signoz";
  clickhouse_data = "${persist}/clickhouse";
  zookeeper_data = "${persist}/zookeeper";
  sqlite_data = "${persist}/sqlite";
  user_scripts = "${persist}/user_scripts";

  net = config.virtualisation.quadlet.networks.signoz;
  zookeeper = config.virtualisation.quadlet.containers.signoz-zookeeper;
  clickhouse = config.virtualisation.quadlet.containers.signoz-clickhouse;
  signoz = config.virtualisation.quadlet.containers.signoz;

  configDir = "/etc/signoz";

  # Version tags
  clickhouseVersion = "25.5.6";
  signozVersion = "v0.105.1";
  otelcolVersion = "v0.129.12";
  zookeeperVersion = "3.7.1";

  # ClickHouse config.xml - simplified for single node
  clickhouseConfig = ''
    <?xml version="1.0"?>
    <clickhouse>
        <logger>
            <level>information</level>
            <formatting><type>json</type></formatting>
            <log>/var/log/clickhouse-server/clickhouse-server.log</log>
            <errorlog>/var/log/clickhouse-server/clickhouse-server.err.log</errorlog>
            <size>100M</size>
            <count>3</count>
        </logger>

        <http_port>8123</http_port>
        <tcp_port>9000</tcp_port>
        <mysql_port>9004</mysql_port>
        <postgresql_port>9005</postgresql_port>
        <interserver_http_port>9009</interserver_http_port>

        <listen_host>0.0.0.0</listen_host>
        <max_connections>4096</max_connections>
        <keep_alive_timeout>3</keep_alive_timeout>
        <max_concurrent_queries>100</max_concurrent_queries>

        <path>/var/lib/clickhouse/</path>
        <tmp_path>/var/lib/clickhouse/tmp/</tmp_path>
        <user_files_path>/var/lib/clickhouse/user_files/</user_files_path>
        <user_scripts_path>/var/lib/clickhouse/user_scripts/</user_scripts_path>
        <format_schema_path>/var/lib/clickhouse/format_schemas/</format_schema_path>

        <user_directories>
            <users_xml><path>users.xml</path></users_xml>
            <local_directory><path>/var/lib/clickhouse/access/</path></local_directory>
        </user_directories>

        <default_profile>default</default_profile>
        <default_database>default</default_database>
        <mlock_executable>true</mlock_executable>

        <macros>
            <shard>01</shard>
            <replica>signoz-01-1</replica>
        </macros>

        <prometheus>
            <endpoint>/metrics</endpoint>
            <port>9363</port>
            <metrics>true</metrics>
            <events>true</events>
            <asynchronous_metrics>true</asynchronous_metrics>
            <status_info>true</status_info>
        </prometheus>

        <distributed_ddl>
            <path>/clickhouse/task_queue/ddl</path>
        </distributed_ddl>

        <query_log>
            <database>system</database>
            <table>query_log</table>
            <partition_by>toYYYYMM(event_date)</partition_by>
            <flush_interval_milliseconds>7500</flush_interval_milliseconds>
        </query_log>

        <metric_log>
            <database>system</database>
            <table>metric_log</table>
            <flush_interval_milliseconds>7500</flush_interval_milliseconds>
            <collect_interval_milliseconds>1000</collect_interval_milliseconds>
        </metric_log>

        <opentelemetry_span_log>
            <engine>engine MergeTree partition by toYYYYMM(finish_date) order by (finish_date, finish_time_us, trace_id)</engine>
            <database>system</database>
            <table>opentelemetry_span_log</table>
            <flush_interval_milliseconds>7500</flush_interval_milliseconds>
        </opentelemetry_span_log>

    </clickhouse>
  '';

  clickhouseUsers = ''
    <?xml version="1.0"?>
    <clickhouse>
        <profiles>
            <default>
                <max_memory_usage>10000000000</max_memory_usage>
                <load_balancing>random</load_balancing>
            </default>
            <readonly>
                <readonly>1</readonly>
            </readonly>
        </profiles>

        <users>
            <default>
                <password></password>
                <networks><ip>::/0</ip></networks>
                <profile>default</profile>
                <quota>default</quota>
            </default>
        </users>

        <quotas>
            <default>
                <interval>
                    <duration>3600</duration>
                    <queries>0</queries>
                    <errors>0</errors>
                    <result_rows>0</result_rows>
                    <read_rows>0</read_rows>
                    <execution_time>0</execution_time>
                </interval>
            </default>
        </quotas>
    </clickhouse>
  '';

  clickhouseCluster = ''
    <?xml version="1.0"?>
    <clickhouse>
        <zookeeper>
            <node index="1">
                <host>signoz-zookeeper</host>
                <port>2181</port>
            </node>
        </zookeeper>

        <remote_servers>
            <cluster>
                <shard>
                    <replica>
                        <host>signoz-clickhouse</host>
                        <port>9000</port>
                    </replica>
                </shard>
            </cluster>
        </remote_servers>
    </clickhouse>
  '';

  clickhouseCustomFunction = ''
    <functions>
        <function>
            <type>executable</type>
            <name>histogramQuantile</name>
            <return_type>Float64</return_type>
            <argument><type>Array(Float64)</type><name>buckets</name></argument>
            <argument><type>Array(Float64)</type><name>counts</name></argument>
            <argument><type>Float64</type><name>quantile</name></argument>
            <format>CSV</format>
            <command>./histogramQuantile</command>
        </function>
    </functions>
  '';

  otelCollectorConfig = ''
    connectors:
      signozmeter:
        metrics_flush_interval: 1h
        dimensions:
          - name: service.name
          - name: deployment.environment
          - name: host.name

    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
          http:
            endpoint: 0.0.0.0:4318
      prometheus:
        config:
          global:
            scrape_interval: 60s
          scrape_configs:
            - job_name: otel-collector
              static_configs:
              - targets:
                  - localhost:8888
                labels:
                  job_name: otel-collector

    processors:
      batch:
        send_batch_size: 10000
        send_batch_max_size: 11000
        timeout: 10s
      batch/meter:
        send_batch_max_size: 25000
        send_batch_size: 20000
        timeout: 1s
      resourcedetection:
        detectors: [env, system]
        timeout: 2s
      signozspanmetrics/delta:
        metrics_exporter: signozclickhousemetrics
        metrics_flush_interval: 60s
        latency_histogram_buckets: [100us, 1ms, 2ms, 6ms, 10ms, 50ms, 100ms, 250ms, 500ms, 1000ms, 1400ms, 2000ms, 5s, 10s, 20s, 40s, 60s]
        dimensions_cache_size: 100000
        aggregation_temporality: AGGREGATION_TEMPORALITY_DELTA
        enable_exp_histogram: true
        dimensions:
          - name: service.namespace
            default: default
          - name: deployment.environment
            default: default
          - name: signoz.collector.id
          - name: service.version
          - name: host.name
          - name: container.name

    extensions:
      health_check:
        endpoint: 0.0.0.0:13133
      pprof:
        endpoint: 0.0.0.0:1777

    exporters:
      clickhousetraces:
        datasource: tcp://signoz-clickhouse:9000/signoz_traces
        low_cardinal_exception_grouping: false
        use_new_schema: true
      signozclickhousemetrics:
        dsn: tcp://signoz-clickhouse:9000/signoz_metrics
      clickhouselogsexporter:
        dsn: tcp://signoz-clickhouse:9000/signoz_logs
        timeout: 10s
        use_new_schema: true
      signozclickhousemeter:
        dsn: tcp://signoz-clickhouse:9000/signoz_meter
        timeout: 45s
        sending_queue:
          enabled: false

    service:
      telemetry:
        logs:
          encoding: json
      extensions:
        - health_check
        - pprof
      pipelines:
        traces:
          receivers: [otlp]
          processors: [signozspanmetrics/delta, batch]
          exporters: [clickhousetraces, signozmeter]
        metrics:
          receivers: [otlp]
          processors: [batch]
          exporters: [signozclickhousemetrics, signozmeter]
        metrics/prometheus:
          receivers: [prometheus]
          processors: [batch]
          exporters: [signozclickhousemetrics, signozmeter]
        logs:
          receivers: [otlp]
          processors: [batch]
          exporters: [clickhouselogsexporter, signozmeter]
        metrics/meter:
          receivers: [signozmeter]
          processors: [batch/meter]
          exporters: [signozclickhousemeter]
  '';

  otelOpampConfig = ''
    server_endpoint: ws://signoz:4320/v1/opamp
  '';

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

  # Create config files
  environment.etc = {
    "signoz/clickhouse/config.xml".text = clickhouseConfig;
    "signoz/clickhouse/users.xml".text = clickhouseUsers;
    "signoz/clickhouse/cluster.xml".text = clickhouseCluster;
    "signoz/clickhouse/custom-function.xml".text = clickhouseCustomFunction;
    "signoz/otel-collector-config.yaml".text = otelCollectorConfig;
    "signoz/otel-collector-opamp-config.yaml".text = otelOpampConfig;
  };

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

  virtualisation.quadlet = {
    networks.signoz = {
      networkConfig = {
        subnets = [ "10.69.4.0/24" ];
        driver = "bridge";
      };
    };

    containers = {
      # --- INIT: Download histogram binary ---
      signoz-init-clickhouse = {
        autoStart = true;
        containerConfig = {
          image = "docker.io/clickhouse/clickhouse-server:${clickhouseVersion}";

          volumes = [ "${user_scripts}:/var/lib/clickhouse/user_scripts" ];

          exec = lib.concatStringsSep " && " [
            ''version="v0.0.1"''
            ''node_os=$(uname -s | tr '[:upper:]' '[:lower:]')''
            ''node_arch=$(uname -m | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)''
            ''echo "Fetching histogram-binary for $node_os/$node_arch"''
            ''cd /tmp''
            ''wget -O histogram-quantile.tar.gz "https://github.com/SigNoz/signoz/releases/download/histogram-quantile%2F$version/histogram-quantile_''${node_os}_''${node_arch}.tar.gz"''
            ''tar -xvzf histogram-quantile.tar.gz''
            ''mv histogram-quantile /var/lib/clickhouse/user_scripts/histogramQuantile''
          ];
        };

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          Restart = "on-failure";
          RestartSec = "5s";
        };

        unitConfig.RequiresMountsFor = user_scripts;
      };

      # --- ZOOKEEPER ---
      signoz-zookeeper = {
        autoStart = true;
        containerConfig = {
          image = "docker.io/signoz/zookeeper:${zookeeperVersion}";
          user = "root";

          networks = [ net.ref ];
          networkAliases = [ "signoz-zookeeper" ];

          volumes = [ "${zookeeper_data}:/bitnami/zookeeper" ];

          environments = {
            ZOO_SERVER_ID = "1";
            ALLOW_ANONYMOUS_LOGIN = "yes";
            ZOO_AUTOPURGE_INTERVAL = "1";
            ZOO_ENABLE_PROMETHEUS_METRICS = "yes";
            ZOO_PROMETHEUS_METRICS_PORT_NUMBER = "9141";
          };

          notify = "healthy";
          healthCmd = "curl -s -m 2 http://localhost:8080/commands/ruok | grep error | grep null";
          healthInterval = "30s";
          healthTimeout = "5s";
          healthRetries = 3;
        };

        serviceConfig.Restart = "always";
        unitConfig.RequiresMountsFor = zookeeper_data;
      };

      # --- CLICKHOUSE ---
      signoz-clickhouse = {
        autoStart = true;
        containerConfig = {
          image = "docker.io/clickhouse/clickhouse-server:${clickhouseVersion}";

          networks = [ net.ref ];
          networkAliases = [ "signoz-clickhouse" ];

          volumes = [
            "${clickhouse_data}:/var/lib/clickhouse"
            "${user_scripts}:/var/lib/clickhouse/user_scripts"
            "${configDir}/clickhouse/config.xml:/etc/clickhouse-server/config.xml:ro"
            "${configDir}/clickhouse/users.xml:/etc/clickhouse-server/users.xml:ro"
            "${configDir}/clickhouse/cluster.xml:/etc/clickhouse-server/config.d/cluster.xml:ro"
            "${configDir}/clickhouse/custom-function.xml:/etc/clickhouse-server/custom-function.xml:ro"
          ];

          environments = {
            CLICKHOUSE_SKIP_USER_SETUP = "1";
          };

          notify = "healthy";
          healthCmd = "wget --spider -q 0.0.0.0:8123/ping";
          healthInterval = "30s";
          healthTimeout = "5s";
          healthRetries = 3;

          podmanArgs = [
            "--ulimit=nproc=65535"
            "--ulimit=nofile=262144:262144"
          ];
        };

        serviceConfig.Restart = "always";

        unitConfig = {
          After = [
            "signoz-init-clickhouse.service"
            zookeeper.ref
          ];
          Requires = [ zookeeper.ref ];
          RequiresMountsFor = clickhouse_data;
        };
      };

      # --- SCHEMA MIGRATOR ---
      signoz-schema-migrator = {
        autoStart = true;
        containerConfig = {
          image = "docker.io/signoz/signoz-schema-migrator:${otelcolVersion}";

          networks = [ net.ref ];

          exec = "sync --dsn=tcp://signoz-clickhouse:9000 --up=";
        };

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          Restart = "on-failure";
          RestartSec = "30s";
        };

        unitConfig = {
          After = [ clickhouse.ref ];
          Requires = [ clickhouse.ref ];
        };
      };

      # --- SIGNOZ (Query Service + UI) ---
      signoz = {
        autoStart = true;
        containerConfig = {
          image = "docker.io/signoz/signoz:${signozVersion}";
          publishPorts = [ "127.0.0.1:8080:8080" ];

          networks = [ net.ref ];
          networkAliases = [ "signoz" ];

          volumes = [ "${sqlite_data}:/var/lib/signoz" ];

          environments = {
            SIGNOZ_ALERTMANAGER_PROVIDER = "signoz";
            SIGNOZ_TELEMETRYSTORE_CLICKHOUSE_DSN = "tcp://signoz-clickhouse:9000";
            SIGNOZ_SQLSTORE_SQLITE_PATH = "/var/lib/signoz/signoz.db";
            STORAGE = "clickhouse";
            GODEBUG = "netdns=go";
            TELEMETRY_ENABLED = "false";
            DEPLOYMENT_TYPE = "docker-standalone";
            DOT_METRICS_ENABLED = "true";
          };

          notify = "healthy";
          healthCmd = "wget --spider -q localhost:8080/api/v1/health";
          healthInterval = "30s";
          healthTimeout = "5s";
          healthRetries = 3;
        };

        serviceConfig.Restart = "always";

        unitConfig = {
          After = [
            clickhouse.ref
            "signoz-schema-migrator.service"
          ];
          Requires = [ clickhouse.ref ];
          RequiresMountsFor = sqlite_data;
        };
      };

      # --- OTEL COLLECTOR (SigNoz internal) ---
      signoz-otel-collector = {
        autoStart = true;
        containerConfig = {
          image = "docker.io/signoz/signoz-otel-collector:${otelcolVersion}";
          publishPorts = [
            "127.0.0.1:4317:4317"
            "127.0.0.1:4318:4318"
          ];

          networks = [ net.ref ];
          networkAliases = [ "signoz-otel-collector" ];

          volumes = [
            "${configDir}/otel-collector-config.yaml:/etc/otel-collector-config.yaml:ro"
            "${configDir}/otel-collector-opamp-config.yaml:/etc/manager-config.yaml:ro"
          ];

          exec = lib.concatStringsSep " " [
            "--config=/etc/otel-collector-config.yaml"
            "--manager-config=/etc/manager-config.yaml"
            "--copy-path=/var/tmp/collector-config.yaml"
            "--feature-gates=-pkg.translator.prometheus.NormalizeName"
          ];

          environments = {
            OTEL_RESOURCE_ATTRIBUTES = "host.name=signoz-host,os.type=linux";
            LOW_CARDINAL_EXCEPTION_GROUPING = "false";
          };
        };

        serviceConfig.Restart = "always";

        unitConfig = {
          After = [ signoz.ref ];
          Requires = [ signoz.ref ];
        };
      };
    };
  };

  # Expose SigNoz via Tailscale
  optx.tailscale.services.signoz = {
    target = "http://localhost:8080";
    port = 443;
    protocol = "https";
    unitConfig = {
      After = [ "signoz.service" ];
      BindsTo = [ "signoz.service" ];
    };
    installConfig.WantedBy = [ "signoz.service" ];
  };
}
