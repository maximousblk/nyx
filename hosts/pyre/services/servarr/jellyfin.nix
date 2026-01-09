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
    target = "http://localhost:${toString port}";
    port = 443;
    protocol = "https";
    unitConfig = {
      After = [ "jellyfin.service" ];
      BindsTo = [ "jellyfin.service" ];
    };
    installConfig = {
      WantedBy = [ "jellyfin.service" ];
    };
  };

  topology.self.services.jellyfin = {
    name = "Jellyfin";
    info = "Media server";
    icon = "services.jellyfin";
  };
}
