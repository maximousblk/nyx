{
  self,
  inputs,
  mkHome,
  withSystem,
  ...
}:
{
  flake = withSystem "x86_64-linux" (
    { system, ... }:
    {
      homeProfiles.umbra = {
        imports = [ ./home.nix ];
      };

      homeConfigurations.umbra = mkHome {
        inherit system;
        username = "ashwin_y";
        homeDirectory = "/home/ashwin_y/.local/share/distrobox/home/umbra";
        modules = [ self.homeProfiles.umbra ];
      };

      deploy.nodes.umbra = {
        hostname = "localhost";
        profiles.home = {
          user = "ashwin_y";
          path = inputs.deploy-rs.lib.${system}.activate.home-manager self.homeConfigurations.umbra;
        };
      };
    }
  );
}
