{
  self,
  mkHome,
  withSystem,
  ...
}:
let
  mkVictus =
    params@{
      username,
      homeDirectory,
      ...
    }:
    {
      _module.args.victus = params;
      imports = [ ./home.nix ];
    };
in
{
  flake = withSystem "x86_64-linux" (
    { system, ... }:
    {
      homeProfiles.mkVictus = mkVictus;

      homeConfigurations.victus = mkHome {
        inherit system;
        modules = [
          (self.homeProfiles.mkVictus {
            username = "maximousblk";
            homeDirectory = "/home/maximousblk";
          })
        ];
      };
    }
  );
}
