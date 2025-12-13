{
  self,
  mkHome,
  withSystem,
  ...
}:
{
  flake = withSystem "x86_64-linux" (
    { ... }:
    {
      homeProfiles.victus = {
        imports = [ ./home.nix ];
      };

      homeConfigurations.victus = mkHome {
        username = "maximousblk";
        homeDirectory = "/home/maximousblk";
        modules = [
          self.homeProfiles.victus
        ];
      };
    }
  );
}
