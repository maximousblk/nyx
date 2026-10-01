{ pkgx, ... }: {
  topology.self.services.headlamp = {
    name = "Headlamp";
    info = "Kubernetes administration UI";
    icon = pkgx.topology-icons.headlamp;
  };

  services.k3s = {
    autoDeployCharts.headlamp = {
      name = "headlamp";
      repo = "https://kubernetes-sigs.github.io/headlamp/";
      version = "0.45.0";
      hash = "sha256-OMYZ4O1dtBZLAsNTvLsk6BV8HZjZYbKS+Z1ozJMWuOs=";
      targetNamespace = "headlamp";
      createNamespace = true;
      values = {
        config = {
          enableHelm = true;
          unsafeUseServiceAccountToken = true;
          pluginsDir = "/build/plugins";
        };
        clusterRoleBinding = {
          create = true;
          clusterRoleName = "cluster-admin";
        };
        initContainers = [
          {
            name = "flux-plugin";
            image = "ghcr.io/headlamp-k8s/headlamp-plugin-flux:v0.7.0";
            command = [
              "/bin/sh"
              "-c"
              "mkdir -p /build/plugins && cp -r /plugins/* /build/plugins/ && chown -R 100:101 /build"
            ];
            securityContext = {
              allowPrivilegeEscalation = false;
              privileged = false;
              runAsGroup = 0;
              runAsNonRoot = false;
              runAsUser = 0;
            };
            volumeMounts = [
              {
                name = "plugins";
                mountPath = "/build/plugins";
              }
            ];
          }
        ];
        volumeMounts = [
          {
            name = "plugins";
            mountPath = "/build/plugins";
          }
        ];
        volumes = [
          {
            name = "plugins";
            emptyDir = { };
          }
        ];
      };
    };

    manifests."12-headlamp-ingress".content = {
      apiVersion = "networking.k8s.io/v1";
      kind = "Ingress";
      metadata = {
        name = "headlamp";
        namespace = "headlamp";
      };
      spec = {
        ingressClassName = "tailscale";
        tls = [ { hosts = [ "headlamp" ]; } ];
        rules = [
          {
            http.paths = [
              {
                path = "/";
                pathType = "Prefix";
                backend.service = {
                  name = "headlamp";
                  port.number = 80;
                };
              }
            ];
          }
        ];
      };
    };
  };
}
