{ modx, ... }:
{
  imports = [
    ./dns.nix
    ./ssh.nix
    ./tailscale.nix
    modx.nixos.opentelemetry-agent
    ./nfs.nix
    ./servarr
  ];

  optx.opentelemetry.agent = {
    enable = true;
    endpoint = "otlp.pony-clownfish.ts.net:4317";
    containerStats = [ "podman" ];
  };
}
