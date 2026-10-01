{ pkgx, ... }: {
  topology.self.services.radar = {
    name = "Radar";
    info = "Kubernetes operations, Helm, and Flux UI";
    icon = pkgx.topology-icons.radar;
  };

  services.k3s = {
    autoDeployCharts.radar = {
      name = "radar";
      repo = "https://skyhook-io.github.io/helm-charts";
      version = "1.14.1";
      hash = "sha256-LVfieFdbCHZkMq6FjRHvZoHFKoLZKJsSM0lwjzNcpCk=";
      targetNamespace = "radar";
      createNamespace = true;
      values = {
        rbac = {
          helm = true;
          podExec = true;
          portForward = true;
          secrets = true;
          viewRBAC = true;
          viewWebhooks = true;
          viewNodeRuntime = true;
        };
        timeline = {
          storage = "sqlite";
          retention = "168h";
          maxSize = "800Mi";
        };
        persistence = {
          enabled = true;
          size = "1Gi";
        };
        mcp.enabled = true;
        initContainers = [
          {
            name = "initialize-helm-home";
            image = "busybox:1.37.0";
            command = [
              "sh"
              "-c"
              "mkdir -p /tmp/helm/cache /tmp/helm/config /tmp/helm/data && printf '%s\\n' 'apiVersion: v1' 'generated: \"1970-01-01T00:00:00Z\"' 'repositories: []' > /tmp/helm/config/repositories.yaml"
            ];
            volumeMounts = [
              {
                name = "tmp";
                mountPath = "/tmp";
              }
            ];
          }
        ];
      };
    };

    manifests."13-radar-ingress".content = {
      apiVersion = "networking.k8s.io/v1";
      kind = "Ingress";
      metadata = {
        name = "radar";
        namespace = "radar";
      };
      spec = {
        ingressClassName = "tailscale";
        tls = [ { hosts = [ "radar" ]; } ];
        rules = [
          {
            http.paths = [
              {
                path = "/";
                pathType = "Prefix";
                backend.service = {
                  name = "radar";
                  port.number = 9280;
                };
              }
            ];
          }
        ];
      };
    };
  };
}
