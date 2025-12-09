{ inputs, withSystem, ... }:
{
  flake = withSystem "x86_64-linux" (
    {
      pkgs,
      pkgx,
      modx,
      ...
    }:
    {

      homeConfigurations.umbra = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs pkgx modx; };
        modules = [ ./home.nix ];
      };

    }
  );
}
