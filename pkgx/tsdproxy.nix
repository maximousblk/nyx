{
  lib,
  buildGoModule,
  bun,
  coreutils,
  fetchFromGitHub,
  go_1_26,
  stdenv,
  templ,
}:
let
  version = "3.0.0-beta.3";

  src = fetchFromGitHub {
    owner = "almeidapaulopt";
    repo = "tsdproxy";
    rev = "v${version}";
    hash = "sha256-GWwhqvzHp3BmejiHkfmo/NswL5/QsDBd2PfqQJk5OTo=";
  };

  frontend = stdenv.mkDerivation {
    pname = "tsdproxy-frontend";
    inherit version src;
    sourceRoot = "source/web";

    nativeBuildInputs = [ bun ];
    outputHashMode = "recursive";
    outputHash =
      {
        aarch64-linux = "sha256-Ekil8xg0qR+8/fAMS0Ex+gXtBDfH1sIkqwDoTA8Buwo=";
        x86_64-linux = "sha256-/b5bqebFDPmvDn4iKMb7oRcFYURsT1UpEMWP5nrIxxQ=";
      }
      .${stdenv.hostPlatform.system};

    buildPhase = ''
      export HOME=$TMPDIR/home
      mkdir -p "$HOME"
      bun install --frozen-lockfile --ignore-scripts --backend=copyfile
      substituteInPlace node_modules/.bin/vite --replace-fail /usr/bin/env ${coreutils}/bin/env
      bun run build
    '';

    installPhase = ''
      cp -r dist $out
    '';
  };
in
(buildGoModule.override { go = go_1_26; }) {
  pname = "tsdproxy";
  inherit version src;

  vendorHash = "sha256-8yem7cV8BU5qNBBKsGeZm54ti1r8qYBY4L3pS6oRRaQ=";
  subPackages = [ "cmd/server" ];
  nativeBuildInputs = [ templ ];

  preBuild = ''
    cp -r ${frontend} web/dist
    templ generate
  '';

  postInstall = ''
    mv $out/bin/server $out/bin/tsdproxy
  '';

  ldflags = [ "-X github.com/almeidapaulopt/tsdproxy/internal/core.version=${version}" ];

  meta = {
    description = "Automatic Tailscale reverse proxy for Docker containers";
    homepage = "https://github.com/almeidapaulopt/tsdproxy";
    license = lib.licenses.mit;
    mainProgram = "tsdproxy";
    platforms = lib.platforms.linux;
  };
}
