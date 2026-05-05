{ inputs, self, ... }:

let
  subs = {
    "https://cache.garnix.io" = "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=";
    "https://attic.xuyh0120.win/lantian" = "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=";
    "https://numtide.cachix.org" = "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE=";
    "https://vicinae.cachix.org" = "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc=";
    "https://hyprland.cachix.org" = "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=";
    "https://nix-community.cachix.org" = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    "https://cache.nixos-cuda.org" = "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=";
  };
in
{
  flake.nixconf = {
    nixpkgs = {
      config.allowUnfree = true;
      overlays = [
        inputs.nur.overlays.default
        inputs.nix-topology.overlays.default
        inputs.fenix.overlays.default
        inputs.nix-cachyos-kernel.overlays.pinned
        inputs.opencode.overlays.default
        (_final: prev: {
          # https://github.com/NixOS/nixpkgs/pull/508770
          opencode = prev.opencode.overrideAttrs (old: {
            postPatch = (old.postPatch or "") + ''
              substituteInPlace package.json --replace-fail 'bun@1.3.13' 'bun@1.3.11'
            '';
          });
        })
        (_final: prev: {
          # https://github.com/NixOS/nixpkgs/issues/426717
          openldap = prev.openldap.overrideAttrs (_: {
            doCheck = !prev.stdenv.hostPlatform.isi686;
          });
        })
      ];
    };

    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        substituters = builtins.attrNames subs;
        trusted-substituters = builtins.attrNames subs;
        trusted-public-keys = builtins.attrValues subs;
        auto-optimise-store = true;
        connect-timeout = 5;
        narinfo-cache-negative-ttl = 86400;
        commit-lockfile-summary = "chore(flake): nix flake update";
      };
      optimise.automatic = true;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };
  };

  flake.nixpkgsConfig = self.nixconf.nixpkgs;
}
