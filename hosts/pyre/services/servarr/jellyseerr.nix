{ config, servarr, ... }:
let
  port = 5055;
in
{
  nixarr.jellyseerr = {
    enable = true;
    openFirewall = false;
    port = port;
  };

  optx.tailscale.services.jellyseerr = {
    serve."https:443" = "http://localhost:${toString port}";
    backends = [ "jellyseerr.service" ];
  };

  topology.self.services.jellyseerr = {
    name = "Jellyseerr";
    info = "Media request management";
    icon = "services.jellyseerr";
  };
}
