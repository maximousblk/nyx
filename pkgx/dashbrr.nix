{ stdenvNoCC, fetchurl }:
stdenvNoCC.mkDerivation {
  pname = "dashbrr";
  version = "0.8.0";
  src = fetchurl {
    url = "https://github.com/autobrr/dashbrr/releases/download/v0.8.0/dashbrr_0.8.0_linux_x86_64.tar.gz";
    hash = "sha256-zuRn+nbXW1Z0Pe9n57Ub2x1bdub0rvZuTautIj1z6uU=";
  };
  sourceRoot = ".";
  installPhase = ''
    install -Dm755 dashbrr $out/bin/dashbrr
  '';
}
