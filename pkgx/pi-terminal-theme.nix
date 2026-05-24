{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation rec {
  pname = "pi-terminal-theme";
  version = "06dc42a43a284a368b90fd82b4f027d6623ee0ab";

  src = fetchFromGitHub {
    owner = "mavam";
    repo = "pi-terminal-theme";
    rev = version;
    hash = "sha256-FWAY3+TLGaAnhhhj6GRftkjK4XAkj5aYZIc2Xqoew8M=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r themes $out/

    runHook postInstall
  '';

  meta = {
    description = "Terminal-first ANSI themes for Pi coding agent";
    homepage = "https://github.com/mavam/pi-terminal-theme";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
