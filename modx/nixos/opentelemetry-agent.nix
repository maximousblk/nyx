{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.optx.opentelemetry.agent;
  hasPodmanStats = builtins.elem "podman" cfg.containerStats;
  hasDockerStats = builtins.elem "docker" cfg.containerStats;
  containerMetricReceivers = lib.optionals hasPodmanStats [ "podman_stats" ] ++ lib.optionals hasDockerStats [ "docker_stats" ];
in
{
  options.optx.opentelemetry.agent = {
    enable = lib.mkEnableOption "OpenTelemetry host agent";

    endpoint = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "OTLP gRPC endpoint for the agent exporter.";
      example = "otlp.pony-clownfish.ts.net:4317";
    };

    containerStats = lib.mkOption {
      type = lib.types.listOf (
        lib.types.enum [
          "podman"
          "docker"
        ]
      );
      default = [ ];
      description = "Container runtime stats receivers to enable.";
      example = [ "podman" ];
    };

    serviceDependencies = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra systemd units the OpenTelemetry agent should wait for.";
      example = [ "signoz-otel-collector.service" ];
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.endpoint != null;
        message = "optx.opentelemetry.agent.endpoint must be set when the agent is enabled";
      }
      {
        assertion = !hasPodmanStats || config.virtualisation.podman.enable;
        message = ''optx.opentelemetry.agent.containerStats includes "podman", but virtualisation.podman.enable is false'';
      }
      {
        assertion = !hasDockerStats || config.virtualisation.docker.enable;
        message = ''optx.opentelemetry.agent.containerStats includes "docker", but virtualisation.docker.enable is false'';
      }
    ];

    services.opentelemetry-collector = {
      enable = true;
      package = pkgs.opentelemetry-collector-contrib;

      settings = {
        extensions = {
          health_check.endpoint = "0.0.0.0:13133";
        };

        receivers = {
          # Host metrics: CPU, memory, disk, filesystem, load, network, paging
          hostmetrics = {
            collection_interval = "60s";
            scrapers = {
              cpu = { };
              disk = {
                exclude = {
                  devices = [
                    "^ram\\d+$"
                    "^zram\\d+$"
                    "^loop\\d+$"
                    "^fd\\d+$"
                  ];
                  match_type = "regexp";
                };
              };
              filesystem = {
                exclude_fs_types = {
                  fs_types = [
                    "autofs"
                    "binfmt_misc"
                    "bpf"
                    "cgroup"
                    "cgroup2"
                    "configfs"
                    "debugfs"
                    "devpts"
                    "devtmpfs"
                    "fusectl"
                    "hugetlbfs"
                    "mqueue"
                    "nsfs"
                    "overlay"
                    "proc"
                    "procfs"
                    "pstore"
                    "rpc_pipefs"
                    "securityfs"
                    "selinuxfs"
                    "squashfs"
                    "sysfs"
                    "tracefs"
                    "tmpfs"
                  ];
                  match_type = "strict";
                };
                exclude_mount_points = {
                  match_type = "regexp";
                  mount_points = [
                    "/dev/*"
                    "/proc/*"
                    "/sys/*"
                    "/run/*"
                    "/var/lib/containers/*"
                    "/nix/store"
                  ];
                };
              };
              load = { };
              memory = { };
              network = {
                exclude = {
                  interfaces = [
                    "^veth.*$"
                    "^docker.*$"
                    "^br-.*$"
                    "^cni.*$"
                    "^dummy.*$"
                    "^lo$"
                  ];
                  match_type = "regexp";
                };
              };
              paging = { };
              process = {
                mute_process_exe_error = true;
                mute_process_io_error = true;
                mute_process_user_error = true;
                mute_process_cgroup_error = true;
              };
              processes = { };
            };
          };

          # Journald logs (includes all systemd units and container logs)
          journald = {
            directory = "/var/log/journal";
            start_at = "end";
            priority = "info";
            all = true;
            operators = [
              # Map syslog PRIORITY to OTel severity (0=emerg -> 7=debug)
              {
                type = "severity_parser";
                parse_from = "body.PRIORITY";
                preset = "none";
                overwrite_text = true;
                mapping = {
                  fatal = [
                    "0"
                    "1"
                    "2"
                  ]; # emerg, alert, crit
                  error = [ "3" ]; # err
                  warn = [ "4" ]; # warning
                  info = [
                    "5"
                    "6"
                  ]; # notice, info
                  debug = [ "7" ]; # debug
                };
              }
              # Map container metadata to OTel semantic conventions
              {
                type = "copy";
                "if" = "body.CONTAINER_ID_FULL != nil";
                from = "body.CONTAINER_ID_FULL";
                to = "resource[\"container.id\"]";
              }
              {
                type = "copy";
                "if" = "body.CONTAINER_NAME != nil";
                from = "body.CONTAINER_NAME";
                to = "resource[\"container.name\"]";
              }
              {
                type = "copy";
                "if" = "body.IMAGE_NAME != nil";
                from = "body.IMAGE_NAME";
                to = "resource[\"container.image.name\"]";
              }
              # Service name from container name or syslog identifier
              {
                type = "copy";
                "if" = "body.CONTAINER_NAME != nil";
                from = "body.CONTAINER_NAME";
                to = "resource[\"service.name\"]";
              }
              {
                type = "copy";
                "if" = "body.SYSLOG_IDENTIFIER != nil and resource[\"service.name\"] == nil";
                from = "body.SYSLOG_IDENTIFIER";
                to = "resource[\"service.name\"]";
              }
              # Unit name
              {
                type = "copy";
                "if" = "body._SYSTEMD_UNIT != nil";
                from = "body._SYSTEMD_UNIT";
                to = "attributes[\"systemd.unit\"]";
              }
              {
                type = "copy";
                "if" = "body._SYSTEMD_SLICE != nil";
                from = "body._SYSTEMD_SLICE";
                to = "attributes[\"systemd.slice\"]";
              }
              # Process info
              {
                type = "copy";
                "if" = "body._PID != nil";
                from = "body._PID";
                to = "attributes[\"process.pid\"]";
              }
              {
                type = "copy";
                "if" = "body._UID != nil";
                from = "body._UID";
                to = "attributes[\"process.user.id\"]";
              }
              {
                type = "copy";
                "if" = "body._GID != nil";
                from = "body._GID";
                to = "attributes[\"process.group.id\"]";
              }
              {
                type = "copy";
                "if" = "body._COMM != nil";
                from = "body._COMM";
                to = "attributes[\"process.command\"]";
              }
              {
                type = "copy";
                "if" = "body._EXE != nil";
                from = "body._EXE";
                to = "attributes[\"process.executable.path\"]";
              }
              # Syslog identifier (separate from service.name)
              {
                type = "copy";
                "if" = "body.SYSLOG_IDENTIFIER != nil";
                from = "body.SYSLOG_IDENTIFIER";
                to = "attributes[\"syslog.appname\"]";
              }
              # Host identification (for multi-host)
              {
                type = "copy";
                "if" = "body._MACHINE_ID != nil";
                from = "body._MACHINE_ID";
                to = "attributes[\"host.id\"]";
              }
              {
                type = "copy";
                "if" = "body._BOOT_ID != nil";
                from = "body._BOOT_ID";
                to = "attributes[\"host.boot.id\"]";
              }
              # Replace JSON body with just the message
              {
                type = "move";
                from = "body.MESSAGE";
                to = "body";
              }
            ];
          };
        }
        // lib.optionalAttrs hasPodmanStats {
          podman_stats = {
            endpoint = "unix:///run/podman/podman.sock";
            collection_interval = "60s";
            timeout = "10s";
          };
        }
        // lib.optionalAttrs hasDockerStats {
          docker_stats = {
            endpoint = "unix:///var/run/docker.sock";
            api_version = "1.40";
            collection_interval = "60s";
            timeout = "10s";
          };
        };

        processors = {
          batch = {
            send_batch_size = 1000;
            timeout = "10s";
          };

          resourcedetection = {
            detectors = [
              "env"
              "system"
            ];
            timeout = "2s";
            system.hostname_sources = [ "os" ];
          };

          # Add deployment environment to all telemetry
          resource = {
            attributes = [
              {
                key = "deployment.environment";
                value = "nyx";
                action = "upsert";
              }
            ];
          };
        };

        exporters = {
          otlp = {
            endpoint = cfg.endpoint;
            tls.insecure = true;
          };
        };

        service = {
          extensions = [ "health_check" ];
          telemetry = {
            logs.level = "info";
            metrics.address = "0.0.0.0:8888";
          };

          pipelines = {
            metrics = {
              receivers = [ "hostmetrics" ] ++ containerMetricReceivers;
              processors = [
                "resourcedetection"
                "resource"
                "batch"
              ];
              exporters = [ "otlp" ];
            };

            logs = {
              receivers = [ "journald" ];
              processors = [
                "resourcedetection"
                "resource"
                "batch"
              ];
              exporters = [ "otlp" ];
            };
          };
        };
      };
    };

    # Ensure collector can read journald and container runtime sockets.
    systemd.services.opentelemetry-collector = {
      after = [ "tailscaled.service" ] ++ cfg.serviceDependencies;
      wants = [ "tailscaled.service" ] ++ cfg.serviceDependencies;

      serviceConfig.SupplementaryGroups = [ "systemd-journal" ] ++ lib.optionals hasPodmanStats [ "podman" ] ++ lib.optionals hasDockerStats [ "docker" ];
    };

    # Enable persistent journal storage
    services.journald.extraConfig = ''
      Storage=persistent
      SystemMaxUse=1G
      MaxRetentionSec=7day
    '';
  };
}
