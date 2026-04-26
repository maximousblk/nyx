{ ... }:
{
  config = {
    networking.hostName = "pyre";
    networking.wireless.enable = false;
    networking.useDHCP = false;
    networking.useNetworkd = true;

    networking.firewall.enable = false;
    networking.firewall.interfaces = {
      "podman*".allowedUDPPorts = [ 53 ];
    };

    systemd.network.networks."10-enp2s0" = {
      matchConfig.Name = "enp2s0";
      address = [ "192.168.69.201/24" ];
      gateway = [ "192.168.69.1" ];
      networkConfig.DHCP = "yes";
    };

    systemd.network.wait-online.extraArgs = [ "--interface=enp2s0" ];
  };
}
