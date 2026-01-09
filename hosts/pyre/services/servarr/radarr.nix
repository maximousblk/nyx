{ servarr, ... }:
let
  port = 7878;
in
{
  nixarr.radarr = {
    enable = true;
    openFirewall = false;
    port = port;
  };

  # Set umask for group write permissions (0002 = rwxrwxr-x for dirs, rw-rw-r-- for files)
  systemd.services.radarr.serviceConfig.UMask = "0002";

  optx.tailscale.services.radarr = {
    target = "http://localhost:${toString port}";
    port = 443;
    protocol = "https";
    unitConfig = {
      After = [ "radarr.service" ];
      BindsTo = [ "radarr.service" ];
    };
    installConfig = {
      WantedBy = [ "radarr.service" ];
    };
  };

  topology.self.services.radarr = {
    name = "Radarr";
    info = "Movie management";
    icon = "services.radarr";
  };
}
