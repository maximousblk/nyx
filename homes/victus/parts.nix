{
  self,
  inputs,
  withSystem,
  ...
}:
{
  flake = withSystem "x86_64-linux" (
    {
      pkgs,
      pkgx,
      modx,
      ...
    }:
    {
      homeProfiles.victus = {
        imports = [ ./home.nix ];
      };

      homeConfigurations.victus = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs pkgx modx; };
        modules = [
          self.homeProfiles.victus
          {
            home.username = "maximousblk";
            home.homeDirectory = "/home/maximousblk";
          }
        ];
      };
    }
  );
}
