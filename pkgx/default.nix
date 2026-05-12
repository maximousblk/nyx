{ pkgs }:

{
  dharmx-walls = pkgs.callPackage ./dharmx-walls.nix { inherit pkgs; };
  mermaid-ascii = pkgs.callPackage ./mermaid-ascii.nix {
    inherit pkgs;
    lib = pkgs.lib;
  };
  polycat = pkgs.callPackage ./polycat.nix { inherit pkgs; };
}
