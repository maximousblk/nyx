{ config, pkgx, ... }: {
  topology.self.services.tailscale-kubernetes = {
    name = "Tailscale Kubernetes Operator";
    info = "Private Kubernetes ingress";
    icon = pkgx.topology-icons.tailscale;
  };

  age.secrets.tailscale-operator-k8s.mode = "0400";

  services.k3s = {
    manifests."01-tailscale-oauth".source = config.age.secrets.tailscale-operator-k8s.path;

    autoDeployCharts.tailscale-operator = {
      name = "tailscale-operator";
      repo = "https://pkgs.tailscale.com/helmcharts";
      version = "1.102.4";
      hash = "sha256-8pioYHdXSQN91vQr92Q2m74oZb3/8CiehkhRpLyQweI=";
      targetNamespace = "tailscale";
      createNamespace = true;
      values = {
        operatorConfig.defaultTags = [ "tag:slop" ];
        proxyConfig.defaultTags = "tag:slop";
      };
    };
  };
}
