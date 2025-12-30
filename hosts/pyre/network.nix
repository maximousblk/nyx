{ ... }:
{
  config = {
    networking.hostName = "pyre";
    networking.wireless.enable = false;
    networking.firewall.enable = false;
    networking.firewall.interfaces = {
      "podman*".allowedUDPPorts = [ 53 ];
    };

    networking.interfaces.enp2s0 = {
      useDHCP = true;
      ipv4.addresses = [
        {
          address = "192.168.69.201";
          prefixLength = 24;
        }
      ];
    };

    networking.defaultGateway = "192.168.69.1";
    networking.nameservers = [ "192.168.69.1" ];
  };
}
