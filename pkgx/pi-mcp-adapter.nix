{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bun,
  cacert,
}:

let
  version = "2.8.0+nix.${builtins.substring 0 8 rev}";
  rev = "1091b34da83d58bd2d9fcaff2dc31f449a94bf1f";
  package = stdenvNoCC.mkDerivation {
    pname = "pi-mcp-adapter";
    inherit version;

    src = fetchFromGitHub {
      owner = "nicobailon";
      repo = "pi-mcp-adapter";
      inherit rev;
      hash = "sha256-eHz/uivSIZ8HOalSCZgyCyOWodQJq5GapAqpT2ryn1k=";
    };

    nativeBuildInputs = [ bun ];

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-rdzoZYWnVYahxREx89q06UMH4D8SsdoNooygiFv/3cw=";

    buildPhase = ''
      runHook preBuild

      export HOME=$TMPDIR/home
      export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
      mkdir -p "$HOME"

      bun install --production --ignore-scripts
      bun build index.ts \
        --target=node \
        --format=esm \
        --outfile=index.js \
        --external='@earendil-works/*' \
        --external=glimpseui \
        --external=chart.js/auto

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp index.js app-bridge.bundle.js $out/

      runHook postInstall
    '';

    meta = {
      description = "Token-efficient MCP adapter extension for Pi coding agent";
      homepage = "https://github.com/nicobailon/pi-mcp-adapter";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
    };
  };
in
{
  inherit package;
  extention = "${package}/index.js";
}
