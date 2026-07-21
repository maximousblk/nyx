{ inputs, self, ... }:

let
  subs = {
    "https://cache.xinux.uz" = "cache.xinux.uz:BXCrtqejFjWzWEB9YuGB7X2MV4ttBur1N8BkwQRdH+0=";
    "https://cache.garnix.io" = "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=";
    "https://attic.xuyh0120.win/lantian" = "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=";
    "https://cache.numtide.com" = "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=";
    "https://numtide.cachix.org" = "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE=";
    "https://vicinae.cachix.org" = "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc=";
    "https://cache.nixos-cuda.org" = "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=";
    "https://hyprland.cachix.org" = "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=";
    "https://noctalia.cachix.org" = "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=";
    "https://nix-community.cachix.org" = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
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
        (
          _final: prev:
          let
            buildGoModule = prev.buildGoModule.override { go = prev.go_1_27; };
            fleet = (prev.fleet.override { inherit buildGoModule; }).overrideAttrs (old: rec {
              version = "4.89.1";
              src = prev.fetchFromGitHub {
                owner = "fleetdm";
                repo = "fleet";
                tag = "fleet-v${version}";
                hash = "sha256-YdKCJoMFX1W9E+o8/st0s29SyHgGy2Tp6Lc045MJUFg=";
              };
              vendorHash = "sha256-caUn3G+rThZ5KOggIHskDk39nPOe4/7DipzDLAEmezU=";
            });
          in
          {
            # https://github.com/NixOS/nixpkgs/pull/507430
            inherit fleet;
            fleetctl = prev.fleetctl.override { inherit buildGoModule fleet; };
          }
        )
        (_final: prev: {
          # https://github.com/NixOS/nixpkgs/issues/468388
          # google-cloud-sdk >= 565 ships Python 3.14 bundled; components.nix
          # hardcodes tcl-8_6 but 3.14 needs tcl9. Pin to older nixpkgs.
          google-cloud-sdk = inputs.nixpkgs-google-cloud-sdk-552.legacyPackages.${prev.stdenv.hostPlatform.system}.google-cloud-sdk;
        })
        (_final: prev: {
          # https://github.com/NixOS/nixpkgs/issues/526914
          # https://github.com/bitwarden/clients/pull/20448
          bitwarden-desktop = prev.bitwarden-desktop.override {
            electron_39 = prev.electron_39.overrideAttrs (old: {
              meta = old.meta // {
                knownVulnerabilities = prev.lib.remove "Electron version 39.8.10 is EOL" old.meta.knownVulnerabilities;
              };
            });
          };
        })
        (_final: prev: {
          # https://github.com/NixOS/nixpkgs/issues/426717
          openldap = prev.openldap.overrideAttrs (_: {
            doCheck = !prev.stdenv.hostPlatform.isi686;
          });
        })
        (_final: prev: {
          # https://github.com/NixOS/nixpkgs/issues/513195
          # https://github.com/NixOS/nixpkgs/pull/531346
          # https://github.com/OrcaSlicer/OrcaSlicer/pull/12308
          # OrcaSlicer's wxGLCanvas uses GLX; EGL-enabled GLEW trips
          # "Missing GL version" and leaves the 3D workspace blank.
          orca-slicer = prev.symlinkJoin {
            name = "orca-slicer-glx";
            paths = [ prev.orca-slicer ];
            nativeBuildInputs = [ prev.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/orca-slicer \
                --set LD_PRELOAD "${(prev.glew.override { enableEGL = false; }).out}/lib/libGLEW.so.2.3"
            '';
          };
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
