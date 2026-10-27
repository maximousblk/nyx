{
  inputs,
  lib,
  self,
  ...
}:

let
  subs = {
    "https://cache.nixos.org/?priority=40" = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
    "https://cache.lantian.pub/lantian?priority=80" = "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ=";
    "https://cache.numtide.com/?priority=41" = "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=";
    "https://numtide.cachix.org/?priority=41" = "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE=";
    "https://prismlauncher.cachix.org/?priority=41" = "prismlauncher.cachix.org-1:9/n/FGyABA2jLUVfY+DEp4hKds/rwO+SCOtbOkDzd+c=";
    "https://vicinae.cachix.org/?priority=41" = "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc=";
    "https://cache.nixos-cuda.org/?priority=50" = "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=";
    "https://hyprland.cachix.org/?priority=41" = "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=";
    "https://noctalia.cachix.org/?priority=41" = "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=";
    "https://nix-community.cachix.org/?priority=41" = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    "https://niri.cachix.org/?priority=41" = "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=";
  };
in
{
  flake.nixconf = {
    nixpkgs = {
      config.allowUnfree = true;
      overlays = [
        (_final: prev: {
          # Use upstream's own nixpkgs pin to preserve its binary-cache identity.
          niri = inputs.niri.packages.${prev.stdenv.hostPlatform.system}.niri-unstable;
        })
        inputs.nur.overlays.default
        (
          final: prev:
          lib.optionalAttrs prev.stdenv.hostPlatform.isAarch64 {
            # Use the ARM release asset's verified content hash.
            nur = prev.nur // {
              repos = prev.nur.repos // {
                xddxdd = prev.nur.repos.xddxdd // {
                  lightpanda = prev.nur.repos.xddxdd.lightpanda.overrideAttrs (old: {
                    src = final.fetchurl {
                      url = "https://github.com/lightpanda-io/browser/releases/download/${old.version}/lightpanda-aarch64-linux";
                      hash = "sha256-aXkZJLzuQ7E7Ikr0yEViLF/mb9vBuBQ7+qOcqPhSRPU=";
                    };
                  });
                };
              };
            };
          }
        )
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
          # Reserve `fx` for the coding agent; expose the file manager as `felix`.
          felix-fm = prev.symlinkJoin {
            name = "felix-fm-renamed";
            paths = [ prev.felix-fm ];
            postBuild = ''
              mv "$out/bin/fx" "$out/bin/felix"
            '';
          };
        })
        (_final: prev: {
          herdr = prev.herdr.overrideAttrs (old: {
            nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
              prev.clang
              prev.lld
            ];
            postPatch = (old.postPatch or "") + ''
              mkdir -p .cargo
              cat >> .cargo/config.toml <<EOF
              [target.x86_64-unknown-linux-gnu]
              linker = "${prev.clang}/bin/clang"
              rustflags = ["-C", "link-arg=-fuse-ld=lld"]
              EOF
            '';
          });
        })
        (_final: prev: {
          # Skip upstream's build-time and installed-package test suites.
          pi-pocket = (prev.callPackage "${inputs.pi-pocket}/nix/package.nix" { }).overrideAttrs (old: {
            doCheck = false;
            doInstallCheck = false;
            # importNpmLock rewrites direct dependencies to store URLs; keep npm's
            # transitive pin tied to that same direct dependency specification.
            npmDeps = prev.importNpmLock {
              npmRoot = inputs.pi-pocket;
              package =
                let
                  p = lib.importJSON "${inputs.pi-pocket}/package.json";
                in
                p
                // {
                  overrides = (p.overrides or { }) // {
                    undici = "$undici";
                  };
                };
            };
            # Wisp uses Tailscale; omit the optional Cloudflare tunnel executable.
            nativeCheckInputs = builtins.filter (p: p != prev.cloudflared) old.nativeCheckInputs;
            installPhase = builtins.appendContext (builtins.unsafeDiscardStringContext (
              builtins.replaceStrings [ ":${lib.makeBinPath [ prev.cloudflared ]}" ] [ "" ] old.installPhase
            )) (builtins.removeAttrs (builtins.getContext old.installPhase) [ (builtins.unsafeDiscardStringContext prev.cloudflared.drvPath) ]);
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
        substituters = lib.mkForce (builtins.attrNames subs);
        trusted-substituters = lib.mkForce (builtins.attrNames subs);
        trusted-public-keys = lib.mkForce (builtins.attrValues subs);
        trusted-users = [
          "root"
          "@wheel"
        ];
        auto-optimise-store = true;
        connect-timeout = 5;
        fallback = true;
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
