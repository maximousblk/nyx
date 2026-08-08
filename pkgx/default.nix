{ pkgs }: {
  dharmx-walls = pkgs.callPackage ./dharmx-walls.nix { inherit pkgs; };
  mermaid-ascii = pkgs.callPackage ./mermaid-ascii.nix { inherit pkgs; };
  polycat = pkgs.callPackage ./polycat.nix { inherit pkgs; };
  pi-web-access = pkgs.callPackage ./pi-web-access.nix { };
  pi-context-mode = pkgs.callPackage ./pi-context-mode.nix { };
  pi-mcp-adapter = pkgs.callPackage ./pi-mcp-adapter.nix { };
}
