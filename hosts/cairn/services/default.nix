{ ... }:
{
  imports = [
    ./ssh.nix
    ./tailscale.nix
    ./zerobyte.nix
  ];

  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";

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
