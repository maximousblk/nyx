{ mkNixos, withSystem, ... }:
{
  flake = withSystem "x86_64-linux" (
    { system, ... }:
    {
      nixosConfigurations.remora = mkNixos {
        inherit system;
        modules = [ ./configuration.nix ];
      };
    }
  );
}
