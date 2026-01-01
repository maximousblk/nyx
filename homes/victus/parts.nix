{
  self,
  mkHome,
  withSystem,
  ...
}:
{
  flake = withSystem "x86_64-linux" (
    { system, ... }:
    {
      homeProfiles.victus = {
        imports = [ ./home.nix ];
      };

      homeConfigurations.victus = mkHome {
        inherit system;
        username = "maximousblk";
        homeDirectory = "/home/maximousblk";
        modules = [ self.homeProfiles.victus ];
      };
    }
  );
}
