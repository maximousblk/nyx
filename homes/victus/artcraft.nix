{ inputs, pkgs, ... }:
let
  # Keep upstream's package set intact to preserve binary-cache hits.
  artcraft = inputs.artcraft.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [ inputs.nix-craftapps.homeManagerModules.default ];

  programs.craftapps = {
    enable = true;
    mcp.enable = true;
    skill.enable = true;
    apps = {
      cadcraft = {
        enable = true;
        package = artcraft.cadcraft;
      };
      deckcraft = {
        enable = true;
        package = artcraft.deckcraft;
      };
      designcraft = {
        enable = true;
        package = artcraft.designcraft;
      };
      effectcraft = {
        enable = true;
        package = artcraft.effectcraft;
      };
      figcraft.enable = false; # Not packaged by the pinned artcraft input.
      filmcraft = {
        enable = true;
        package = artcraft.filmcraft;
      };
      gridcraft = {
        enable = true;
        package = artcraft.gridcraft;
      };
      lightcraft = {
        enable = true;
        package = artcraft.lightcraft;
      };
      pdfcraft = {
        enable = true;
        package = artcraft.pdfcraft;
      };
      photocraft = {
        enable = true;
        package = artcraft.photocraft;
      };
      soundcraft = {
        enable = true;
        package = artcraft.soundcraft;
      };
      vectorcraft = {
        enable = true;
        package = artcraft.vectorcraft;
      };
      wordcraft = {
        enable = true;
        package = artcraft.wordcraft;
      };
    };
  };
}
