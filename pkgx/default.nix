{ pkgs }:

{
  dharmx-walls = pkgs.callPackage ./dharmx-walls.nix { inherit pkgs; };
  polycat = pkgs.callPackage ./polycat.nix { inherit pkgs; };
}
