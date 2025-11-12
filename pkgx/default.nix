{ pkgs }:

{
  dharmx-walls = pkgs.callPackage ./dharmx-walls.nix { inherit pkgs; };
}
