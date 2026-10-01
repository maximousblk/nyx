{
  lib,
  modx,
  pkgx,
  pkgs,
  ...
}:
{
  imports = [
    modx.nixos.opentelemetry-agent
    ./tailscale.nix
    ./flux.nix
    ./headlamp.nix
    ./radar.nix
    ./openbao.nix

  ];

  services.k3s = {
    enable = true;
    extraFlags = [ "--secrets-encryption" ];
  };

  topology.self.services = {
    k3s = {
      name = "K3s";
      info = "Single-node Kubernetes cluster";
      icon = pkgx.topology-icons.k3s;
    };
    opentelemetry-collector = {
      name = "OpenTelemetry Collector";
      info = "Host and Kubernetes telemetry exporter";
      icon = pkgx.topology-icons.opentelemetry;
    };
  };

  environment.systemPackages = [ pkgs.kubectl ];

  optx.opentelemetry.agent = {
    enable = true;
    endpoint = "otlp.pony-clownfish.ts.net:4317";
    serviceDependencies = [ "k3s.service" ];
    extraReceivers = {
      kubeletstats = {
        auth_type = "kubeConfig";
        collection_interval = "20s";
        endpoint = "erebus";
      };
      k8s_cluster = {
        auth_type = "kubeConfig";
        collection_interval = "10s";
        allocatable_types_to_report = [
          "cpu"
          "memory"
        ];
        metrics = {
          "k8s.pod.status_reason".enabled = true;
        };
      };
    };
  };

  services.opentelemetry-collector = {
    validateConfigFile = false;
    settings = {
      receivers.k8sobjects = {
        auth_type = "kubeConfig";
        objects = [
          {
            group = "events.k8s.io";
            mode = "watch";
            name = "events";
            exclude_watch_type = [ "DELETED" ];
          }
        ];
      };
      processors.resource.attributes = lib.mkAfter [
        {
          key = "k8s.cluster.name";
          value = "erebus";
          action = "upsert";
        }
      ];
      service.pipelines.logs.receivers = lib.mkAfter [ "k8sobjects" ];
    };
  };

  systemd.services.opentelemetry-collector.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "root";
    Environment = [ "KUBECONFIG=/etc/rancher/k3s/k3s.yaml" ];
  };

  networking.firewall.trustedInterfaces = [
    "cni0"
    "flannel.1"
  ];
}
