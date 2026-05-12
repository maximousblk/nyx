{ config, servarr, ... }:
let
  port = 5055;
in
{
  nixarr.seerr = {
    enable = true;
    openFirewall = false;
    port = port;
  };

  optx.tailscale.services.seerr = {
    serve."https:443" = "http://localhost:${toString port}";
    backends = [ "seerr.service" ];
  };

  topology.self.services.seerr = {
    name = "Seerr";
    info = "Media request management";
    icon = "services.seerr";
  };
}
