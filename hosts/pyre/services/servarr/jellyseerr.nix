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
    target = "http://localhost:${toString port}";
    port = 443;
    protocol = "https";
    unitConfig = {
      After = [ "jellyseerr.service" ];
      BindsTo = [ "jellyseerr.service" ];
    };
    installConfig = {
      WantedBy = [ "jellyseerr.service" ];
    };
  };

  topology.self.services.jellyseerr = {
    name = "Jellyseerr";
    info = "Media request management";
    icon = "services.jellyseerr";
  };
}
