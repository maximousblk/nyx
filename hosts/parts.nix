{
  lib,
  self,
  inputs,
  withSystem,
  ...
}:
{
  imports = [
    ./victus/parts.nix
    ./pyre/parts.nix
    ./remora/parts.nix
    ./cairn/parts.nix
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

              { nix = self.nixconf.nix; }

              {
                home-manager.useGlobalPkgs = false;
                home-manager.useUserPackages = true;
                home-manager.backupFileExtension = "hm_bak";
                home-manager.sharedModules = homeManagerModules ++ [
                  { nixpkgs = self.nixpkgsConfig; }
                ];
                home-manager.extraSpecialArgs = { inherit inputs pkgx modx; };
              }
            ]
            ++ modules;
        }
      )
    );
  };
}
