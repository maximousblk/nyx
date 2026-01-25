{ lib, ... }:
let
  port = 9091;
in
{
  nixarr.transmission = {
    enable = true;
    openFirewall = false;
    peerPort = 51413;
    uiPort = port;
    flood.enable = false;
    messageLevel = "warn";
    extraSettings = {
      ratio-limit-enabled = true;
      ratio-limit = 0;
      idle-seeding-limit-enabled = true;
      idle-seeding-limit = 1;
    };
  };

  systemd.services.transmission.serviceConfig.UMask = lib.mkForce "0002";

  optx.tailscale.services.transmission = {
    target = "http://localhost:${toString port}";
    port = 443;
    protocol = "https";
    unitConfig = {
      After = [ "transmission.service" ];
      BindsTo = [ "transmission.service" ];
    };
    installConfig = {
      WantedBy = [ "transmission.service" ];
    };
  };

  topology.self.services.transmission = {
    name = "Transmission";
    info = "Torrent client";
    icon = "services.transmission";
  };
}
