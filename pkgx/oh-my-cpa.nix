{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation {
  pname = "oh-my-cpa";
  version = "0.3.25";
  src = fetchurl {
    url = "https://github.com/WizisCool/oh-my-cpa/releases/download/v0.3.25/oh-my-cpa_0.3.25_linux_arm64.tar.gz";
    hash = "sha256-T31o02wsbXF/C1xH16eFz7UUNLVcbjpC8k3D/nOdLRA=";
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
