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
        };
        clusterRoleBinding = {
          create = true;
          clusterRoleName = "cluster-admin";
        };
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
