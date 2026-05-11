{ ... }:
{
  config = {
    networking.firewall.checkReversePath = "loose";

    services.tailscale = {
      enable = true;
      useRoutingFeatures = "both";
      extraSetFlags = [
        "--auto-update=false"
        "--ssh=false"
        "--report-posture"
      ];
      openFirewall = true;
    };
  };
}
