{ pkgs, ... }:

{
  home.pointerCursor = {
    package = pkgs.rose-pine-cursor;
    name = "BreezeX-RoséPine";
    size = 24;

    gtk.enable = true;
    x11.enable = true;
  };
}
