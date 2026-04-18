{ lib, servarr, ... }:
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
  systemd.services.sonarr.serviceConfig.UMask = lib.mkForce "0002";

  optx.tailscale.services.sonarr = {
    serve."https:443" = "http://localhost:${toString port}";
    backends = [ "sonarr.service" ];
  };

  topology.self.services.sonarr = {
    name = "Sonarr";
    info = "TV show management";
    icon = "services.sonarr";
  };
}
