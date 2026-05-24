{
  lib,
  stdenv,
  fetchFromGitHub,
  bun,
  nodejs,
  cacert,
  python3,
}:

stdenv.mkDerivation {
  pname = "pi-context-mode";
  version = "dd8477cf066d2f839241875d3a0a5a54ca2771a3";

  src = fetchFromGitHub {
    owner = "mksglu";
    repo = "context-mode";
    rev = "dd8477cf066d2f839241875d3a0a5a54ca2771a3";
    hash = "sha256-yuURTBFVlPfnGqW7DnVgDAWSrF/f1whLl4wZRXlGZSM=";
  };

  nativeBuildInputs = [
    bun
    nodejs
    python3
  ];

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "sha256-Bv4ynwfRbHuHqoeoAr+oop+hNK1mOXxT6rfi7Jxw61s=";

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR/home
    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
    export GYP_DEFINES="openssl_fips="
    mkdir -p "$HOME"

    bun install --frozen-lockfile --ignore-scripts
    node node_modules/typescript/bin/tsc
    node -e "if(process.platform!=='win32'){require('fs').chmodSync('build/cli.js',0o755)}"
    node node_modules/esbuild/bin/esbuild src/server.ts --bundle --platform=node --target=node18 --format=esm --outfile=server.bundle.mjs --external:better-sqlite3 --external:turndown --external:turndown-plugin-gfm --external:@mixmark-io/domino --minify
    node node_modules/esbuild/bin/esbuild src/cli.ts --bundle --platform=node --target=node18 --format=esm --outfile=cli.bundle.mjs --external:better-sqlite3 --minify
    node node_modules/esbuild/bin/esbuild src/session/extract.ts --bundle --platform=node --target=node18 --format=esm --outfile=hooks/session-extract.bundle.mjs --minify
    node node_modules/esbuild/bin/esbuild src/session/snapshot.ts --bundle --platform=node --target=node18 --format=esm --outfile=hooks/session-snapshot.bundle.mjs --minify
    node node_modules/esbuild/bin/esbuild src/session/db.ts --bundle --platform=node --target=node18 --format=esm --outfile=hooks/session-db.bundle.mjs --external:better-sqlite3 --minify
    node node_modules/esbuild/bin/esbuild src/security.ts --bundle --platform=node --target=node18 --format=esm --outfile=hooks/security.bundle.mjs --minify

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r build $out/
    cp server.bundle.mjs $out/
    cp -r skills $out/
    cp -r hooks $out/

    runHook postInstall
  '';

  meta = {
    description = "Context-saving MCP plugin for coding agents with sandboxed execution and FTS5 knowledge base";
    homepage = "https://github.com/mksglu/context-mode";
    license = lib.licenses.unfree; # Elastic-2.0
    platforms = lib.platforms.all;
  };
}
