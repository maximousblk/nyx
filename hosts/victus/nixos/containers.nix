{ ... }:
{
  virtualisation.podman.enable = true;

  virtualisation.oci-containers.containers.torproxy = {
    image = "zhaowde/rotating-tor-http-proxy";

    autoStart = true;

    ports = [ "127.0.0.1:4444:4444" ];

    environment = {
      TOR_INSTANCES = "3";
      TOR_REBUILD_INTERVAL = "14400";
    };
  };
}
