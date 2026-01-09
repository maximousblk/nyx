{ servarr, ... }:
let
  port = 8989;
in
{
  nixarr.sonarr = {
    enable = true;
    openFirewall = false;
    port = port;
  };

  # Set umask for group write permissions (0002 = rwxrwxr-x for dirs, rw-rw-r-- for files)
  systemd.services.sonarr.serviceConfig.UMask = "0002";

  optx.tailscale.services.sonarr = {
    target = "http://localhost:${toString port}";
    port = 443;
    protocol = "https";
    unitConfig = {
      After = [ "sonarr.service" ];
      BindsTo = [ "sonarr.service" ];
    };
    installConfig = {
      WantedBy = [ "sonarr.service" ];
    };
  };

  topology.self.services.sonarr = {
    name = "Sonarr";
    info = "TV show management";
    icon = "services.sonarr";
  };
}
