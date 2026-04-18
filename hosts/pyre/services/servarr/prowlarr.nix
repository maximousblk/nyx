{ servarr, ... }:
let
  port = 9696;
in
{
  nixarr.prowlarr = {
    enable = true;
    openFirewall = false;
    port = port;
  };

  optx.tailscale.services.prowlarr = {
    serve."https:443" = "http://localhost:${toString port}";
    backends = [ "prowlarr.service" ];
  };

  topology.self.services.prowlarr = {
    name = "Prowlarr";
    info = "Indexer manager";
    icon = "services.prowlarr";
  };
}
