{
  modx,
  pkgs,
  lib,
  ...
}:
let
  collector = pkgs.stdenvNoCC.mkDerivation {
    pname = "opentelemetry-collector-contrib";
    version = "0.165.0";
    src = pkgs.fetchurl {
      url = "https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.165.0/otelcol-contrib_0.165.0_linux_arm64.tar.gz";
      hash = "sha256-N2QgcpyGIjCAe8iYEdB9EAMerso/ZIH+Nxor3O/SyPo=";
    };
    dontUnpack = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      tar -xzf $src -C $out/bin otelcol-contrib
      runHook postInstall
    '';
    meta.mainProgram = "otelcol-contrib";
  };
in
{
  imports = [
    modx.nixos.opentelemetry-agent
    ./crafty.nix
    # ./load.nix
    ./flaresolverr.nix
    ./tsidp.nix
    ./signoz.nix
    ./ssh.nix
    ./tailscale.nix
    ./omp-auth.nix
    ./cliproxyapi.nix
    ./proxy.nix
    ./torproxy.nix
  ];

  optx.opentelemetry.agent = {
    enable = true;
    endpoint = "otlp.pony-clownfish.ts.net:4317";
    containerStats = [ "docker" ];
    serviceDependencies = [ "signoz-otel-collector.service" ];
  };
  services.opentelemetry-collector.package = lib.mkForce collector;
}
