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
      rpc-host-whitelist-enabled = false;
    };
  };

  systemd.services.transmission.serviceConfig.UMask = lib.mkForce "0002";

  optx.tailscale.services.transmission = {
    serve."https:443" = "http://localhost:${toString port}";
    backends = [ "transmission.service" ];
  };

  topology.self.services.transmission = {
    name = "Transmission";
    info = "Torrent client";
    icon = "services.transmission";
  };
}
