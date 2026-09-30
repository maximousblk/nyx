{ pkgx, ... }: {
  topology.self.services.scrutiny = {
    name = "Scrutiny";
    info = "Disk health monitoring";
    icon = pkgx.topology-icons.scrutiny;
  };

  services.scrutiny = {
    enable = true;
    openFirewall = false;
    settings.web.listen.host = "127.0.0.1";
    collector = {
      enable = true;
      schedule = "daily";
    };
  };

  optx.tailscale.services.scrutiny = {
    serve."https:443" = "http://localhost:8080";
    backends = [ "scrutiny.service" ];
  };
}
