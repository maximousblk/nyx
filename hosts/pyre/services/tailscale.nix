{ ... }:
{
  config = {
    networking.firewall.checkReversePath = "loose";

    services.tailscale = {
      enable = true;
      useRoutingFeatures = "both";
      extraUpFlags = [ ];
      extraSetFlags = [
        "--advertise-exit-node"
        "--advertise-routes=192.168.69.0/24,fd7a:115c:a1e0:b1a:0:2:c0a8:4500/120"
        "--operator=maximousblk"
        "--auto-update=false"
        "--ssh=false"
        "--report-posture"
      ];
      extraDaemonFlags = [ ];
      openFirewall = true;
    };
  };
}
