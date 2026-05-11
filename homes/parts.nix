{
  lib,
  inputs,
  self,
  withSystem,
  ...
}:
let
  homeModules = [
    inputs.noctalia.homeModules.default
    inputs.vicinae.homeManagerModules.default
    inputs.nix-index-database.homeModules.nix-index
    { nixpkgs = self.nixpkgsConfig; }
  ];
in
{
  imports = [
    ./umbra/parts.nix
    ./victus/parts.nix
  ];

  options = {
    flake = {
      homeConfigurations = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = { };
      };
      homeProfiles = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = { };
      };
    };
  };
  config = {
    _module.args.mkHome =
      { name, module }:
      let
        mkProfile =
          params@{ username, homeDirectory, ... }:
          {
            _module.args.${name} = params;
            imports = homeModules ++ [
              module
              {
                home.username = username;
                home.homeDirectory = homeDirectory;
              }
            ];
          };

        mkConfig =
          params@{ system, ... }:
          withSystem system (
            {
              pkgs,
              pkgx,
              modx,
              ...
            }:
            inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;

              extraSpecialArgs = {
                inherit
                  inputs
                  self
                  pkgx
                  modx
                  ;
              };

              modules = [ (mkProfile (builtins.removeAttrs params [ "system" ])) ];
            }
          );
      in
      {
        inherit mkProfile mkConfig;
      };
  };
}
