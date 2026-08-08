{
  lib,
  stdenv,
  fetchFromGitHub,
  bun,
  nodejs,
  cacert,
  python3,
}:

let
  version = "1.0.151+nix.${builtins.substring 0 8 rev}";
  rev = "99590934970aa7f1008de16adb500e320e2b8ccb";
  package = stdenv.mkDerivation {
    pname = "pi-context-mode";
    inherit version;

    src = fetchFromGitHub {
      owner = "mksglu";
      repo = "context-mode";
      inherit rev;
      hash = "sha256-W/hytzXMXV2SrKWOa5hrwoWR9XcH2CHEJHr0GmMXljU=";
    };

    nativeBuildInputs = [
      bun
      nodejs
      python3
    ];

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-UitX1VLmVCkRu9V6JvKXFLSvR1h+hmVcBiVx8mre89s=";

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

      mkdir -p $out/pi-context-mode
      cp -r build $out/pi-context-mode/
      cp server.bundle.mjs package.json $out/pi-context-mode/
      test -f $out/pi-context-mode/package.json
      cp -r skills $out/pi-context-mode/
      cp -r hooks $out/pi-context-mode/

      runHook postInstall
    '';

    meta = {
      description = "Context-saving MCP plugin for coding agents with sandboxed execution and FTS5 knowledge base";
      homepage = "https://github.com/mksglu/context-mode";
      license = lib.licenses.unfree; # Elastic-2.0
      platforms = lib.platforms.all;
    };
  };
in
{
  inherit package;
  extension = "${package}/pi-context-mode/build/adapters/pi/extension.js";
  skills = "${package}/pi-context-mode/skills";
}
