{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bun,
  cacert,
}:

stdenvNoCC.mkDerivation rec {
  pname = "pi-mcp-adapter";
  version = "c28c3608e4dd0e7eaf92cc4306ea9875bc60e077";

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-mcp-adapter";
    rev = version;
    hash = "sha256-DYQp/wgrEIqY7nVhJSB2oAVU+TZsWrI25BO0pxlmteg=";
  };

  nativeBuildInputs = [ bun ];

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "sha256-L0wAkAV2rFxWmmMJYODGQAw5G0szE0cIVR/TT36ALH8=";

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
}
