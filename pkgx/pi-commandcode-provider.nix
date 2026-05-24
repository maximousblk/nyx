{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bun,
}:

stdenvNoCC.mkDerivation {
  pname = "pi-commandcode-provider";
  version = "b5b109c63c8c258c039b16be0d15c5173222d76a";

  src = fetchFromGitHub {
    owner = "patlux";
    repo = "pi-commandcode-provider";
    rev = "b5b109c63c8c258c039b16be0d15c5173222d76a";
    hash = "sha256-WXPJd3VypB6b2odxwXwfYzG2Gr8i3AP3ugvWn/k6xEc=";
  };

  nativeBuildInputs = [ bun ];

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "sha256-teCWUQ/hQYpWBcK5ag28mkerLb4EWpOdQuetwuYp430=";

  postPatch = ''
    substituteInPlace index.ts \
      --replace-fail '@mariozechner/pi-ai' '@earendil-works/pi-ai' \
      --replace-fail '@mariozechner/pi-coding-agent' '@earendil-works/pi-coding-agent'
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
}
