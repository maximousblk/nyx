{ pkgs, pkgx, ... }: {
  topology.self.services.flux = {
    name = "Flux";
    info = "GitOps controllers and status UI";
    icon = pkgx.topology-icons.flux;
  };

  services.k3s = {
    manifests."10-flux-operator".source = pkgs.fetchurl {
      url = "https://github.com/controlplaneio-fluxcd/flux-operator/releases/download/v0.60.0/install.yaml";
      hash = "sha256-7198KuUoENiG9rzMZqD+07Q286d5fnmlnARD8ZHd0C4=";
    };

    manifests."11-flux-instance".content = {
      apiVersion = "fluxcd.controlplane.io/v1";
      kind = "FluxInstance";
      metadata = {
        name = "flux";
        namespace = "flux-system";
      };
      spec = {
        distribution = {
          version = "2.8.x";
          registry = "ghcr.io/fluxcd";
        };
        cluster = {
          type = "kubernetes";
          size = "small";
        };
      };
    };

    manifests."12-flux-ingress".content = {
      apiVersion = "networking.k8s.io/v1";
      kind = "Ingress";
      metadata = {
        name = "flux-operator";
        namespace = "flux-system";
      };
      spec = {
        ingressClassName = "tailscale";
        tls = [ { hosts = [ "flux" ]; } ];
        rules = [
          {
            http.paths = [
              {
                path = "/";
                pathType = "Prefix";
                backend.service = {
                  name = "flux-operator";
                  port.number = 9080;
                };
              }
            ];
          }
        ];
      };
    };
  };
}
