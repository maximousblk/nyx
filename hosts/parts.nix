{
  lib,
  self,
  inputs,
  withSystem,
  ...
}:
let
  nixosModules = [
    inputs.disko.nixosModules.disko
    inputs.nixarr.nixosModules.default
    inputs.quadlet-nix.nixosModules.quadlet
    inputs.home-manager.nixosModules.home-manager
    inputs.impermanence.nixosModules.impermanence
    inputs.nixos-facter-modules.nixosModules.facter
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nix-topology.nixosModules.default
  ];
in
{
  imports = [
    ./victus/parts.nix
    ./pyre/parts.nix
    ./remora/parts.nix
    ./cairn/parts.nix
    ./scry/parts.nix
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
                home-manager.extraSpecialArgs = {
                  inherit
                    inputs
                    self
                    pkgx
                    modx
                    ;
                };
              }
            ]
            ++ modules;
        }
      )
    );
  };
}
