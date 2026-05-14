{ ... }:
{
  config = {
    networking.hostName = "cairn";
    networking.wireless.enable = false;
    networking.useDHCP = false;
    networking.useNetworkd = true;

    networking.firewall.enable = false;

    systemd.network.networks."10-enp0s31f6" = {
      matchConfig.Name = "enp0s31f6";
      networkConfig.DHCP = "yes";
      linkConfig.RequiredForOnline = "routable";
    };

    systemd.network.wait-online.extraArgs = [ "--interface=enp0s31f6" ];
  };
}
