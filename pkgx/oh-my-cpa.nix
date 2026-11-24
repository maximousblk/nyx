{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation {
  pname = "oh-my-cpa";
  version = "0.4.13";
  src = fetchurl {
    url = "https://github.com/WizisCool/oh-my-cpa/releases/download/v0.4.13/oh-my-cpa_0.4.13_linux_arm64.tar.gz";
    hash = "sha256-Y9ktpyAxem0B+lGzxgxScN6mJa/hcJegHntpfxONe3s=";
  };
  sourceRoot = ".";
  installPhase = ''
    runHook preInstall
    install -Dm755 oh-my-cpa $out/bin/oh-my-cpa
    runHook postInstall
  '';
  meta = {
    description = "CLIProxyAPI management and usage console";
    homepage = "https://github.com/WizisCool/oh-my-cpa";
    mainProgram = "oh-my-cpa";
    platforms = [ "aarch64-linux" ];
    license = lib.licenses.mit;
  };
}
