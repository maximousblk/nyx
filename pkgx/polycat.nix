{ pkgs }:
pkgs.stdenv.mkDerivation rec {
  pname = "polycat";
  version = "2.0.0+nix.${builtins.substring 0 8 src.rev}";

  src = pkgs.fetchFromGitHub {
    owner = "2IMT";
    repo = "polycat";
    rev = "f81e73bbb5de90a496bb0b844cdb3a93e54fbaad";
    hash = "sha256-wpDx6hmZe/dLv+F+kbo+YUIZ2A8XgnrZP0amkz6I5IQ=";
  };

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "POLYCAT_VERSION=${version}"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 build/polycat $out/bin/polycat
    install -Dm644 res/polycat.ttf $out/share/fonts/truetype/polycat.ttf
    install -Dm644 res/polycat-config $out/share/polycat/polycat-config

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "runcat module for polybar (or waybar) written in C++";
    homepage = "https://github.com/2IMT/polycat";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
