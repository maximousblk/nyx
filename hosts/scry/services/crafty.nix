{ modx, pkgx, ... }: {
  topology.self.services = {
    crafty = {
      name = "Crafty Controller";
      info = "Minecraft server management";
      icon = pkgx.topology-icons.crafty;
    };
    minecraft = {
      name = "Minecraft";
      info = "Java game server";
      icon = "services.minecraft";
    };
  };

  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";

  virtualisation.oci-containers.containers.crafty = {
    serviceName = "crafty";
    image = "registry.gitlab.com/crafty-controller/crafty-4:4.11.0";
    pull = "always";
    ports = [
      "8443:8443"
      "25565:25565"
    ];
    # Persist only the five state paths documented by Crafty's Docker guide.
    # https://docs.craftycontrol.com/pages/getting-started/installation/docker/#mount-locations
    volumes = [
      "crafty-backups:/crafty/backups"
      "crafty-logs:/crafty/logs"
      "crafty-servers:/crafty/servers"
      "crafty-config:/crafty/app/config"
      "crafty-import:/crafty/import"
    ];
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
