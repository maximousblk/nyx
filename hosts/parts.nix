{
  self,
  inputs,
  withSystem,
  ...
}:
{
  imports = [
    ./victus/parts.nix
  ];

  config = {
    _module.args.mkNixos = (
      {
        modules,
        system,
      }:
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

          modules = [
            {
              nixpkgs.pkgs = pkgs;
              nixpkgs.hostPlatform = system;
            }

            inputs.sops-nix.nixosModules.sops
            inputs.nix-index-database.nixosModules.nix-index
          ]
          ++ modules;
        }
      )
    );
  };
}
