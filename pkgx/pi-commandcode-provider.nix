{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bun,
}:

let
  rev = "f48291f252e73f1b63c17cc57f34a3cc8498144d";
  package = stdenvNoCC.mkDerivation {
    pname = "pi-commandcode-provider";
    version = "0.3.1+nix.${builtins.substring 0 8 rev}";

    src = fetchFromGitHub {
      owner = "patlux";
      repo = "pi-commandcode-provider";
      inherit rev;
      hash = "sha256-AOmTp+9SdBlnkty+sfEgFlcSNZ5y63iCHkEo3agP+Cg=";
    };

    nativeBuildInputs = [ bun ];

    postPatch = ''
        substituteInPlace src/converters.ts \
          --replace-fail \
            '  const out: unknown[] = []' \
            '  messages?.forEach(m => { if (!["user", "assistant", "system"].includes(m.role)) m.role = "assistant" })
      const out: unknown[] = []'
    '';

    buildPhase = ''
      runHook preBuild

      bun build index.ts \
        --target=node \
        --format=esm \
        --outfile=index.js \
        --external='@earendil-works/*'

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp index.js $out/

      runHook postInstall
    '';

    meta = {
      description = "Command Code provider extension for Pi coding agent";
      homepage = "https://github.com/patlux/pi-commandcode-provider";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
    };
  };
in
{
  inherit package;
  extention = "${package}/index.js";
}
