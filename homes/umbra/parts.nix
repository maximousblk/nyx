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
      homeConfigurations.umbra = mkHome {
        inherit withSystem;
        username = "ashwin_y";
        homeDirectory = "/home/ashwin_y/.local/share/distrobox/home/umbra";
        modules = [
          self.homeManagerModules.umbra
        ];
      };
    }
  );
}
