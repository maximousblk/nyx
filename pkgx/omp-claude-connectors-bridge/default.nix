{
  lib,
  stdenvNoCC,
  writeShellApplication,
  bun,
}:

let
  package = stdenvNoCC.mkDerivation {
    pname = "omp-claude-connectors-bridge";
    version = "1.0.0";

    src = ./.;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/omp-claude-connectors-bridge/skills/omp-claude-connectors-bridge
      cp index.ts $out/omp-claude-connectors-bridge/
      cp SKILL.md $out/omp-claude-connectors-bridge/skills/omp-claude-connectors-bridge/

      runHook postInstall
    '';

    meta = {
      description = "Claude account MCP connectors for Pi and OMP through the existing Claude login";
      platforms = lib.platforms.all;
    };
  };
in
{
  inherit package;
  extension = "${package}/omp-claude-connectors-bridge/index.ts";
  skills = "${package}/omp-claude-connectors-bridge/skills";
  cli = writeShellApplication {
    name = "omp-claude-connectors-bridge";
    runtimeInputs = [ bun ];
    text = ''
      exec bun ${package}/omp-claude-connectors-bridge/index.ts "$@"
    '';
  };
}
