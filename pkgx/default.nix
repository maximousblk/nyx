{ pkgs }:

{
  dharmx-walls = pkgs.callPackage ./dharmx-walls.nix { inherit pkgs; };
  nur-taskrunner = pkgs.callPackage ./nur-taskrunner.nix {
    inherit pkgs;
    lib = pkgs.lib;
  };
  polycat = pkgs.callPackage ./polycat.nix { inherit pkgs; };
}
