{ modx, ... }: {
  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";

  virtualisation.oci-containers.containers.crafty = {
    serviceName = "crafty";
    image = "registry.gitlab.com/crafty-controller/crafty-4:latest";
    pull = "always";
    ports = [
      "8443:8443"
      "25565:25565"
    ];
    volumes = [ "crafty:/crafty" ];
  };

  optx.tailscale = {
    services.crafty = {
      serve."https:443" = "https+insecure://localhost:8443";
      backends = [ "crafty.service" ];
    };

    tsdproxy = {
      nodes.minecraft = {
        backends = [ "crafty.service" ];
        ports = {
          "25565/tcp".targets = [ "tcp://127.0.0.1:25565" ];
        };
      };
    };
  };

}
