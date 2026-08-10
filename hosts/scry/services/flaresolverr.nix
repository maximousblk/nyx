{ ... }: {
  virtualisation.oci-containers.containers.flaresolverr = {
    serviceName = "flaresolverr";
    image = "ghcr.io/flaresolverr/flaresolverr:v3.4.6";
    pull = "always";
    ports = [ "8191:8191" ];
    environment.LOG_LEVEL = "info";
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8191 ];

  topology.self.services.flaresolverr = {
    name = "FlareSolverr";
    info = "Cloudflare challenge solver";
    icon = builtins.fetchurl {
      url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/flaresolverr.svg";
      sha256 = "1cvv2iybfyc9zcpvcphzp347gpv28fk5wnylwcf6z7bfrqdjij4z";
    };
  };

}
