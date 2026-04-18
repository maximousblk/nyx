{ config, servarr, ... }:
let
  port = 8096;
in
{
  nixarr.jellyfin = {
    enable = true;
    openFirewall = false;
  };

  users.users.jellyfin.extraGroups = [
    "video"
    "render"
  ];

  optx.tailscale.services.jellyfin = {
    serve."https:443" = "http://localhost:${toString port}";
    backends = [ "jellyfin.service" ];
  };

  topology.self.services.jellyfin = {
    name = "Jellyfin";
    info = "Media server";
    icon = "services.jellyfin";
  };
}
