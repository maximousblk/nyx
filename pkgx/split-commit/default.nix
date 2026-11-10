{
  lib,
  pkgs,
  stdenvNoCC,
}:

let
  flakeLockDiff = pkgs.stdenv.mkDerivation {
    pname = "flake-lock-diff";
    version = "1.0";
    dontUnpack = true;
    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.nix.dev ];

    buildPhase = ''
      runHook preBuild
      $CXX ${./flake-lock-diff.cc} -o flake-lock-diff $(pkg-config --cflags --libs nix-flake)
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      install -Dm755 flake-lock-diff $out/bin/flake-lock-diff
      runHook postInstall
    '';
  };
  package = stdenvNoCC.mkDerivation {
    pname = "split-commit";
    version = "1.0";
    src = ./.;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 -t "$out/bin" scripts/split-commit-*
      install -Dm755 ${flakeLockDiff}/bin/flake-lock-diff $out/bin/flake-lock-diff
      install -Dm644 SKILL.md $out/share/skills/split-commit/SKILL.md
      runHook postInstall
    '';

    meta = {
      description = "Safe Git helpers and agent skill for splitting changes into commits";
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
    };
  };
in
{
  inherit package;
  skills = "${package}/share/skills";
}
