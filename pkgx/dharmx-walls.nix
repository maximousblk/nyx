{ pkgs }:
pkgs.stdenv.mkDerivation {
  pname = "dharmx-walls";
  version = "2025.10.25";

  src = pkgs.fetchFromGitHub {
    owner = "dharmx";
    repo = "walls";
    rev = "6bf4d733ebf2b484a37c17d742eb47e5139e6a14";
    hash = "sha256-M96jJy3L0a+VkJ+DcbtrRAquwDWaIG9hAUxenr/TcQU=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out

    ${pkgs.fd}/bin/fd . --type f \
      --extension jpg \
      --extension jpeg \
      --extension png \
      --exec cp {} $out/

    chmod 444 $out/*

    runHook postInstall
  '';

  __structuredAttrs = true;
}
