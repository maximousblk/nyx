{ ... }:
{
  virtualisation.quadlet.containers.torproxy = {
    autoStart = true;
    containerConfig = {
      image = "docker.io/dockurr/tor:latest";
      pull = "always";
      publishPorts = [ "127.0.0.1:9050:9050" ];
    };
    serviceConfig.Restart = "always";
  };

  topology.self.services.torproxy = {
    name = "Tor Proxy";
    info = "SOCKS5 proxy with remote DNS";
    icon = builtins.fetchurl {
      url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/tor.svg";
      sha256 = "05i9mmb34k9mfdxysaizr8mmyabs06kvnji6yr9b6zm4iy4k0af2";
    };
  };
}
