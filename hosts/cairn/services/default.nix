{ modx, ... }:
{
  imports = [
    modx.nixos.opentelemetry-agent
    ./ssh.nix
    ./tailscale.nix
    ./zerobyte.nix
  ];

  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";

  optx.opentelemetry.agent = {
    enable = true;
    endpoint = "otlp.pony-clownfish.ts.net:4317";
    containerStats = [ "docker" ];
  };

  _module.args.common = {
    env = {
      TZ = "Asia/Kolkata";
    };

    paths = {
      data = "/mnt/data";
      volumes = "/var/lib/volumes";
    };
  };
}
