{ pkgs }:

{
  dharmx-walls = pkgs.callPackage ./dharmx-walls.nix { inherit pkgs; };
  mermaid-ascii = pkgs.callPackage ./mermaid-ascii.nix {
    inherit pkgs;
    lib = pkgs.lib;
  };
  polycat = pkgs.callPackage ./polycat.nix { inherit pkgs; };
  pi-commandcode-provider =
    let
      package = pkgs.callPackage ./pi-commandcode-provider.nix { };
    in
    {
      inherit package;
      extention = "${package}/index.js";
    };

  pi-mcp-adapter =
    let
      package = pkgs.callPackage ./pi-mcp-adapter.nix { };
    in
    {
      inherit package;
      extention = "${package}/index.js";
    };

  pi-web-access =
    let
      package = pkgs.callPackage ./pi-web-access.nix { };
    in
    {
      inherit package;
      extention = "${package}/index.js";
      skills = "${package}/skills";
    };

  pi-context-mode =
    let
      package = pkgs.callPackage ./pi-context-mode.nix { };
    in
    {
      inherit package;
      extention = "${package}/build/adapters/pi/extension.js";
      skills = "${package}/skills";
    };
}
