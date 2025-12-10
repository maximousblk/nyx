{ lib, ... }:
let
  subs = {
    "https://hyprland.cachix.org" =
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=";
    "https://nix-gaming.cachix.org" =
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=";
    "https://vicinae.cachix.org" = "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc=";
    "https://cache.garnix.io" = "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=";
  };
in
{
  config.nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      substituters = lib.attrNames subs;
      trusted-substituters = lib.attrNames subs;
      trusted-public-keys = lib.attrValues subs;
      auto-optimise-store = true;
      connect-timeout = 5;
      commit-lockfile-summary = "nix: update flake";
    };

    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
