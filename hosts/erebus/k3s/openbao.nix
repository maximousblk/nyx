{ config, pkgx, ... }: {
  topology.self.services.openbao = {
    name = "OpenBao";
    info = "Secrets management";
    icon = pkgx.topology-icons.openbao;
  };

  age.secrets.openbao-static-seal.mode = "0400";

  services.k3s = {
    manifests."01-openbao-static-seal".source = config.age.secrets.openbao-static-seal.path;

    autoDeployCharts.openbao = {
      name = "openbao";
      repo = "https://openbao.github.io/openbao-helm";
      version = "0.29.6";
      hash = "sha256-gHnphb32CPllraWccAUWk9FN0kVKwWMRIp82fQxIxLk=";
      targetNamespace = "openbao";
      createNamespace = true;
      values = {
        server = {
          updateStrategyType = "RollingUpdate";
          ha = {
            enabled = true;
            replicas = 1;
            raft = {
              enabled = true;
              config = ''
                ui = true
                listener "tcp" {
                  tls_disable = 1
                  address = "[::]:8200"
                  cluster_address = "[::]:8201"
                }
                storage "raft" {
                  path = "/openbao/data"
                }
                service_registration "kubernetes" {}
                seal "static" {
                  current_key_id = "primary"
                  current_key = "file:///openbao/secrets/static-seal/key"
                }
              '';
            };
          };
          volumes = [
            {
              name = "static-seal";
              secret = {
                secretName = "openbao-static-seal";
                defaultMode = 288;
              };
            }
          ];
          volumeMounts = [
            {
              name = "static-seal";
              mountPath = "/openbao/secrets/static-seal";
              readOnly = true;
            }
          ];
        };
        injector.enabled = false;
        ui.enabled = true;
      };
    };

    manifests."11-openbao-ingress".content = {
      apiVersion = "networking.k8s.io/v1";
      kind = "Ingress";
      metadata = {
        name = "openbao";
        namespace = "openbao";
      };
      spec = {
        ingressClassName = "tailscale";
        tls = [ { hosts = [ "openbao" ]; } ];
        rules = [
          {
            http.paths = [
              {
                path = "/";
                pathType = "Prefix";
                backend.service = {
                  name = "openbao-ui";
                  port.number = 8200;
                };
              }
            ];
          }
        ];
      };
    };
  };
}
