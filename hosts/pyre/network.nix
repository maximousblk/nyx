{ ... }:
{
  config = {
    networking.hostName = "pyre";
    networking.wireless.enable = false;
    networking.firewall.enable = false;
    networking.firewall.interfaces = {
      "podman*".allowedUDPPorts = [ 53 ];
    };
  };
}
