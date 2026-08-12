{ modx, ... }: {
  imports = [
    modx.nixos.opentelemetry-agent
    ./load.nix
    ./flaresolverr.nix
    ./tsidp.nix
    ./signoz.nix
    ./ssh.nix
    ./tailscale.nix
    ./proxy.nix
    ./torproxy.nix
  ];

  optx.opentelemetry.agent = {
    enable = true;
    endpoint = "otlp.pony-clownfish.ts.net:4317";
    containerStats = [ "docker" ];
    serviceDependencies = [ "signoz-otel-collector.service" ];
  };
}
