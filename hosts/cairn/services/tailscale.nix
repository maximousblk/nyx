{ ... }:
{
  config = {
    networking.firewall.checkReversePath = "loose";

    services.tailscale = {
      enable = true;
      useRoutingFeatures = "both";
      extraUpFlags = [ "--advertise-tags=tag:nyx" ];
      extraSetFlags = [
        "--auto-update=false"
        "--ssh=false"
        "--report-posture"
      ];
      openFirewall = true;
    };
  };
}
