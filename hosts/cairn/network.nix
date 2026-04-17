{ ... }:
{
  config = {
    networking.hostName = "cairn";
    networking.wireless.enable = false;
    networking.firewall.enable = false;

    networking.interfaces.enp0s31f6 = {
      useDHCP = true;
      ipv4.addresses = [
        {
          address = "192.168.69.203";
          prefixLength = 24;
        }
      ];
      mtu = 1280;
    };

    networking.defaultGateway = "192.168.69.1";
    networking.nameservers = [ "192.168.69.1" ];
  };
}
