{ pkgs }:
let
  python = pkgs.python3.withPackages (ps: [
    ps.pillow
    ps.imagehash
  ]);

  filterScript = ./scripts/filter_wallpapers.py;
in
pkgs.stdenv.mkDerivation {
  pname = "dharmx-walls";
  version = "2025.10.25";

  src = pkgs.fetchFromGitHub {
    owner = "dharmx";
    repo = "walls";
    rev = "6bf4d733ebf2b484a37c17d742eb47e5139e6a14";
    hash = "sha256-M96jJy3L0a+VkJ+DcbtrRAquwDWaIG9hAUxenr/TcQU=";
  };

  nativeBuildInputs = [ python ];

  dontBuild = true;
  allowSubstitutes = false;

  installPhase = ''
    runHook preInstall

    ${python}/bin/python3 ${filterScript} \
      "$src" "$out" \
      --jobs "$NIX_BUILD_CORES"

    runHook postInstall
  '';

  __structuredAttrs = true;
}
