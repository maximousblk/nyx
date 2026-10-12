{ stdenvNoCC, fetchurl }:
stdenvNoCC.mkDerivation {
  pname = "dashbrr";
  version = "0.7.0";
  src = fetchurl {
    url = "https://github.com/autobrr/dashbrr/releases/download/v0.7.0/dashbrr_0.7.0_linux_x86_64.tar.gz";
    hash = "sha256-D2romzRk3X9hnXeN1UlGQE49DzsjNxu22XffJrBFWhQ=";
  };
  sourceRoot = ".";
  installPhase = ''
    install -Dm755 dashbrr $out/bin/dashbrr
  '';
}
