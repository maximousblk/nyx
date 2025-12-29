{ pkgs, lib }:

pkgs.rustPlatform.buildRustPackage {
  pname = "nur";
  version = "0.21.1";

  src = pkgs.fetchFromGitHub {
    owner = "nur-taskrunner";
    repo = "nur";
    rev = "66eced28c8c8383e56e2fd95dcb47489ed4e2540";
    hash = "sha256-sCh6pzCmxp/FDIA8K/Mt/FGqgg71zFGaA7vTrtAyQaM=";
  };

  cargoHash = "sha256-ptjqNxROWi6SaYTHZA2jQ5UyePUXhmffsXU2Llx5H/E=";

  meta = {
    description = "A taskrunner based on nu shell";
    homepage = "https://github.com/nur-taskrunner/nur";
    license = lib.licenses.mit;
    mainProgram = "nur";
  };
}
