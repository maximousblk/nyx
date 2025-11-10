{ lib, ... }:
let
  subs = {
    "https://hyprland.cachix.org" =
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=";
    "https://nix-gaming.cachix.org" =
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=";
    "https://vicinae.cachix.org" = "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc=";
    "https://chaotic-nyx.cachix.org" =
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8=";
  };
in
{
  config = {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      substituters = lib.attrNames subs;
      trusted-substituters = lib.attrNames subs;
      trusted-public-keys = lib.attrValues subs;
    };
  };
}
