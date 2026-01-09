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
    target = "http://localhost:${toString port}";
    port = 443;
    protocol = "https";
    unitConfig = {
      After = [ "prowlarr.service" ];
      BindsTo = [ "prowlarr.service" ];
    };
    installConfig = {
      WantedBy = [ "prowlarr.service" ];
    };
  };

  topology.self.services.prowlarr = {
    name = "Prowlarr";
    info = "Indexer manager";
    icon = "services.prowlarr";
  };
}
