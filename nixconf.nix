{ inputs, self, ... }:

let
  subs = {
    "https://cache.garnix.io" = "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=";
    "https://attic.xuyh0120.win/lantian" = "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=";
    "https://numtide.cachix.org" = "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE=";
    "https://cache.numtide.com" = "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=";
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
        inputs.llm-agents.overlays.default
        (_final: prev: {
          # https://github.com/NixOS/nixpkgs/pull/507430
          fleet = prev.fleet.overrideAttrs (_: rec {
            version = "4.85.0";
            src = prev.fetchFromGitHub {
              owner = "fleetdm";
              repo = "fleet";
              tag = "fleet-v${version}";
              hash = "sha256-MXqUfDGk0u2+eCvP1dmb4dxF+LPJQ+YudqMAxAVPZJc=";
            };
            vendorHash = "sha256-Zu5VxrH+MnxqDEZj2gljfaKyCqGDQSLZqjsDjeCJ2h8=";
          });
        })
        (_final: prev: {
          # https://github.com/NixOS/nixpkgs/issues/468388
          # google-cloud-sdk >= 565 ships Python 3.14 bundled; components.nix
          # hardcodes tcl-8_6 but 3.14 needs tcl9. Pin to older nixpkgs.
          google-cloud-sdk = inputs.nixpkgs-google-cloud-sdk-552.legacyPackages.${prev.stdenv.hostPlatform.system}.google-cloud-sdk;
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
          "pipe-operators"
        ];
        substituters = builtins.attrNames subs;
        trusted-substituters = builtins.attrNames subs;
        trusted-public-keys = builtins.attrValues subs;
        trusted-users = [
          "root"
          "@wheel"
        ];
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
