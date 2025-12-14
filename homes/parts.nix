{
  lib,
  inputs,
  withSystem,
  ...
}:
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
    _module.args.mkHome = (
      {
        modules,
        system,
        username ? null,
        homeDirectory ? null,
      }:
      withSystem system (
        {
          pkgs,
          pkgx,
          modx,
          homeManagerModules,
          ...
        }:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = { inherit inputs pkgx modx; };

          modules = [

          ]
          ++ homeManagerModules
          ++ modules
          ++ lib.optional (username != null) {
            home.username = username;
            home.homeDirectory = homeDirectory;
          };
        }
      )
    );
  };
}
