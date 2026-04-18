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
      address = [ "192.168.69.203/24" ];
      gateway = [ "192.168.69.1" ];
      dns = [ "192.168.69.1" ];
      linkConfig.MTUBytes = "1280";
      networkConfig.DHCP = "yes";
    };

    systemd.network.wait-online.extraArgs = [ "--interface=enp0s31f6" ];
  };
}
