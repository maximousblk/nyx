{
  inputs,
  lib,
  self,
  ...
}:

let
  subs = {
    "https://cache.nixos.org/?priority=40" = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
    "https://cache.xinux.uz/?priority=80" = "cache.xinux.uz:BXCrtqejFjWzWEB9YuGB7X2MV4ttBur1N8BkwQRdH+0=";
    "https://attic.xuyh0120.win/lantian?priority=80" = "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=";
    "https://cache.numtide.com/?priority=41" = "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=";
    "https://numtide.cachix.org/?priority=41" = "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE=";
    "https://vicinae.cachix.org/?priority=41" = "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc=";
    "https://cache.nixos-cuda.org/?priority=50" = "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=";
    "https://hyprland.cachix.org/?priority=41" = "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=";
    "https://noctalia.cachix.org/?priority=41" = "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=";
    "https://nix-community.cachix.org/?priority=41" = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
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
          # https://github.com/NixOS/nixpkgs/issues/426717
          openldap = prev.openldap.overrideAttrs (_: {
            doCheck = !prev.stdenv.hostPlatform.isi686;
          });
        })
        (
          _final: prev:
          let
            glewZip = prev.fetchurl {
              url = "https://github.com/nigels-com/glew/releases/download/glew-2.2.0/glew-2.2.0.zip";
              hash = "sha256-qQRqkTd0OVoJXtzAsKwtgcOqzKYXh7OYOblB6b4U4NQ=";
            };
          in
          {
            # Expose glibc startup objects and libgcc_s to Arc's Jnigen linker.
            # https://github.com/NixOS/nixpkgs/issues/544566
            # https://github.com/NixOS/nixpkgs/commit/2b169ebe89d6fad56a1c84298d15f2c9ee5d8c60
            # https://github.com/NixOS/nixpkgs/pull/542111
            mindustry-wayland = prev.mindustry-wayland.overrideAttrs (old: {
              buildInputs = old.buildInputs ++ [
                prev.libGLU.dev
                prev.libglvnd.dev
                prev.libX11.dev
                prev.xorgproto
              ];
              postPatch = old.postPatch + ''
                      cp ${glewZip} ../Arc/backends/backend-sdl/build/jnigen/sources/glew.zip
                      ${prev.unzip}/bin/unzip -qq -d ../Arc/backends/backend-sdl/build/jnigen/sources ${glewZip}
                      substituteInPlace ../Arc/arc-core/build.gradle \
                        --replace-fail 'linkerFlags += ["-flto"]' \
                        'linkerFlags += ["-flto", "-B${prev.stdenv.cc.libc}/lib", "-L${prev.stdenv.cc.cc.libgcc}/lib"]'
                      substituteInPlace ../Arc/backends/backend-sdl/build.gradle \
                        --replace-fail 'headerDirs = ["$mainRoot/glew-2.2.0/include"]' \
                        'headerDirs = ["$mainRoot/glew-2.2.0/include"]
                headerDirs += ["${prev.libGLU.dev}/include", "${prev.libglvnd.dev}/include", "${prev.libX11.dev}/include", "${prev.xorgproto}/include"]' \
                        --replace-fail 'linkerFlags = "-shared -m64".split(" ")' \
                        'linkerFlags = "-shared -m64 -B${prev.stdenv.cc.libc}/lib -L${prev.stdenv.cc.cc.libgcc}/lib".split(" ")'
                      substituteInPlace ../Arc/extensions/filedialogs/build.gradle \
                        --replace-fail 'cIncludes = ["csrc/tinyfiledialogs.c"]' \
                        'cIncludes = ["csrc/tinyfiledialogs.c"]
                linkerFlags += "-B${prev.stdenv.cc.libc}/lib -L${prev.stdenv.cc.cc.libgcc}/lib".split(" ")'
                      substituteInPlace ../Arc/extensions/freetype/build.gradle \
                        --replace-fail 'cppFlags += "-DFT2_BUILD_LIBRARY"' \
                        'cppFlags += "-DFT2_BUILD_LIBRARY"
                linkerFlags += "-B${prev.stdenv.cc.libc}/lib -L${prev.stdenv.cc.cc.libgcc}/lib".split(" ")'
              '';
            });
          }
        )
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
