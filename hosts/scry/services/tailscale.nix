{ ... }:
{
  networking.firewall.checkReversePath = "loose";

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    extraSetFlags = [
      "--advertise-exit-node"
      "--advertise-routes=10.42.0.0/24"
      "--operator=maximousblk"
      "--auto-update=false"
      "--ssh=false"
      "--report-posture"
    ];
    openFirewall = true;
  };
}
