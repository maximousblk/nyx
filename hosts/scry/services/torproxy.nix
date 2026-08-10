{ ... }: {
  virtualisation.oci-containers.containers.torproxy = {
    serviceName = "torproxy";
    image = "docker.io/dockurr/tor:0.4.9";
    pull = "always";
    ports = [
      "9050:9050"
      "8119:8118"
    ];
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    9050
    8119
  ];

  topology.self.services.torproxy = {
    name = "Tor Proxy";
    info = "SOCKS5 proxy with remote DNS";
    icon = "services.tor";
  };
}
