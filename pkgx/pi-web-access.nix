{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bun,
  cacert,
}:

let
  version = "0.10.7+nix.${builtins.substring 0 8 rev}";
  rev = "076bf0db5e739b200286ca37486e4edd8d19123c";
  package = stdenvNoCC.mkDerivation {
    pname = "pi-web-access";
    inherit version;

    src = fetchFromGitHub {
      owner = "nicobailon";
      repo = "pi-web-access";
      inherit rev;
      hash = "sha256-D9no4SLigH/t3/WfirixMbTEjcEwZwJXld8j7pwBCew=";
    };

    nativeBuildInputs = [ bun ];

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-bwK6hpJELJFu7sA7RZrFMrti0PWwknpFbBldEzuWauo=";

    postPatch = ''
      substituteInPlace index.ts \
        --replace-fail '@mariozechner/pi-coding-agent' '@earendil-works/pi-coding-agent' \
        --replace-fail '@mariozechner/pi-tui' '@earendil-works/pi-tui' \
        --replace-fail '@mariozechner/pi-ai' '@earendil-works/pi-ai'
      substituteInPlace storage.ts \
        --replace-fail '@mariozechner/pi-coding-agent' '@earendil-works/pi-coding-agent'
      substituteInPlace summary-review.ts \
        --replace-fail '@mariozechner/pi-coding-agent' '@earendil-works/pi-coding-agent' \
        --replace-fail '@mariozechner/pi-ai' '@earendil-works/pi-ai'
    '';

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
        --external=typebox

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp index.js $out/
      cp -r skills $out/

      runHook postInstall
    '';

    meta = {
      description = "Web search, URL fetching, GitHub, PDF, YouTube, and video access for Pi coding agent";
      homepage = "https://github.com/nicobailon/pi-web-access";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
    };
  };
in
{
  inherit package;
  extention = "${package}/index.js";
  skills = "${package}/skills";
}
