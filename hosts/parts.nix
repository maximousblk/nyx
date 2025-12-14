{
  lib,
  self,
  inputs,
  withSystem,
  ...
}:
let
  subs = {
    "https://cache.garnix.io" = "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=";
    "https://numtide.cachix.org" = "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE=";
    "https://vicinae.cachix.org" = "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc=";
    "https://hyprland.cachix.org" = "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=";
    "https://nix-gaming.cachix.org" = "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=";
    "https://nix-community.cachix.org" = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
  };
in
{
  imports = [
    ./victus/parts.nix
    ./pyre/parts.nix
  ];

  options = {
    flake = {
      deploy.nodes = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = { };
      };
    };
  };

  config = {
    _module.args.mkNixos = (
      { modules, system }:
      withSystem system (
        {
          pkgs,
          pkgx,
          modx,
          nixosModules,
          homeManagerModules,
          ...
        }:
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs self;
            inherit pkgx modx;
          };

          modules =
            nixosModules
            ++ [
              {
                nixpkgs.pkgs = pkgs;
                nixpkgs.hostPlatform = system;
              }

              {
                nix = {
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

              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.backupFileExtension = "hm_bak";
                home-manager.sharedModules = homeManagerModules;
                home-manager.extraSpecialArgs = { inherit inputs pkgx modx; };
              }
            ]
            ++ modules;
        }
      )
    );
  };
}
