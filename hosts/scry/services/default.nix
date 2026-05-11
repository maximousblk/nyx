{ modx, ... }:
{
  imports = [
    modx.nixos.opentelemetry-agent
    ./load.nix
    ./signoz.nix
    ./ssh.nix
    ./tailscale.nix
  ];

  optx.opentelemetry.agent = {
    enable = true;
    endpoint = "otlp.pony-clownfish.ts.net:4317";
    containerStats = [ "docker" ];
    serviceDependencies = [ "signoz-otel-collector.service" ];
  };
}
