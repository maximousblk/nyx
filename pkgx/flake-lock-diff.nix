{
  lib,
  stdenv,
  nix,
  pkg-config,
}:
stdenv.mkDerivation {
  pname = "flake-lock-diff";
  version = "1.0";
  dontUnpack = true;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ nix.dev ];

  # Reuse Nix's semantic input diff without resolving inputs or writing files.
  buildPhase = ''
    runHook preBuild
    cat > main.cc <<'CPP'
    #include <iostream>
    #include "nix/fetchers/fetch-settings.hh"
    #include "nix/flake/lockfile.hh"
    #include "nix/util/error.hh"
    #include "nix/util/file-system.hh"
    #include "nix/util/terminal.hh"

    int main(int argc, char **argv)
    {
        if (argc != 3) {
            std::cerr << "Usage: flake-lock-diff OLD.lock NEW.lock\n";
            return 2;
        }
        try {
            nix::experimentalFeatureSettings.experimentalFeatures = {nix::Xp::Flakes};
            nix::fetchers::Settings settings;
            nix::flake::LockFile oldLocks(settings, nix::readFile(argv[1]), argv[1]);
            nix::flake::LockFile newLocks(settings, nix::readFile(argv[2]), argv[2]);
            std::cout << nix::filterANSIEscapes(nix::flake::LockFile::diff(oldLocks, newLocks), true);
        } catch (const nix::Error &error) {
            std::cerr << "flake-lock-diff: " << nix::filterANSIEscapes(error.what(), true) << '\n';
            return 1;
        }
    }
    CPP
    $CXX main.cc -o flake-lock-diff $(pkg-config --cflags --libs nix-flake)
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 flake-lock-diff $out/bin/flake-lock-diff
    runHook postInstall
  '';

  meta = {
    description = "Compare two flake lockfiles using Nix's native semantic diff";
    mainProgram = "flake-lock-diff";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
