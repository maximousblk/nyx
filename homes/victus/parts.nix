{ mkHome, ... }:
let
  victus = mkHome {
    name = "victus";
    module = ./home.nix;
  };
in
{
  flake = {
    homeProfiles.victus = victus.mkProfile;

    homeConfigurations.victus = victus.mkConfig {
      system = "x86_64-linux";
      username = "maximousblk";
      homeDirectory = "/home/maximousblk";
    };
  };
}
