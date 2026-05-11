{ ... }:
{
  networking.hostName = "scry";
  networking.wireless.enable = false;
  networking.useDHCP = false;
  networking.useNetworkd = true;

  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [
      22
      80
      443
    ];
  };

  systemd.network.networks."10-enp0s6" = {
    matchConfig.Name = "enp0s6";
    networkConfig.DHCP = "ipv4";
    linkConfig.RequiredForOnline = "routable";
  };

  systemd.network.wait-online.extraArgs = [ "--interface=enp0s6" ];
}
