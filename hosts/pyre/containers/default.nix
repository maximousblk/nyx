{ ... }:
{
  imports = [
    ./immich.nix
    ./karakeep.nix
    ./paperless.nix
    ./signoz.nix
    ./torproxy.nix
  ];

  config = {
    virtualisation.podman = {
      enable = true;
      autoPrune.enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    virtualisation.oci-containers.backend = "podman";

    virtualisation.quadlet = {
      autoEscape = true;
      networks.main = {
        networkConfig = {
          subnets = [ "10.69.0.0/24" ];
          gateways = [ "10.69.0.1" ];
          driver = "bridge";
          ipv6 = false;
        };
      };
    };

    _module.args.common = {
      env = {
        PUID = "1000";
        PGID = "100";
        TZ = "Asia/Kolkata";
      };

      paths = {
        data = "/mnt/data";
        volumes = "/var/lib/volumes";
      };
    };
  };
}
