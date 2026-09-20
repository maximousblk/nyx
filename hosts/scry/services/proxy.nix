{ pkgx, ... }: {
  services.sing-box = {
    enable = true;
    settings = {
      log.level = "info";

      inbounds = [
        {
          type = "http";
          tag = "http-in";
          listen = "0.0.0.0";
          listen_port = 8118;
        }
        {
          type = "socks";
          tag = "socks-in";
          listen = "0.0.0.0";
          listen_port = 1080;
        }
      ];

      outbounds = [
        {
          type = "direct";
          tag = "direct-out";
        }
      ];
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    8118
    1080
  ];

  topology.self.services.proxy = {
    name = "Network Proxy";
    info = "Direct HTTP and SOCKS5 proxy";
    icon = pkgx.topology-icons.proxy;
  };
}
