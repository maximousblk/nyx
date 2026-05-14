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
      networkConfig.DHCP = "yes";
      linkConfig.RequiredForOnline = "routable";
    };

    systemd.network.wait-online.extraArgs = [ "--interface=enp2s0" ];
  };
}
