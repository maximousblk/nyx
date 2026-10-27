{
  modx,
  pkgs,
  lib,
  ...
}:
let
  collector = pkgs.stdenvNoCC.mkDerivation {
    pname = "opentelemetry-collector-contrib";
    version = "0.163.2";
    src = pkgs.fetchurl {
      url = "https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.163.2/otelcol-contrib_0.163.2_linux_arm64.tar.gz";
      hash = "sha256-0jniGc+BmTIT/aL9befcH5Ip0yaYxF0t177DG2nBwAQ=";
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
