{ modx, ... }:
{
  imports = [
    modx.nixos.opentelemetry-agent
    ./ly.nix
    ./niri.nix
    ./packages.nix
    ./services.nix
  ];

  optx.opentelemetry.agent = {
    enable = true;
    endpoint = "otlp.pony-clownfish.ts.net:4317";
    containerStats = [ ];
  };
}
