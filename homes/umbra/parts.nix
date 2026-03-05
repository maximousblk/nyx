{
  self,
  inputs,
  mkHome,
  withSystem,
  ...
}:
let
  mkUmbra =
    params@{
      username,
      homeDirectory,
      containerHost,
    }:
    {
      _module.args.umbra = params;
      imports = [ ./home.nix ];
    };
in
{
  flake = withSystem "x86_64-linux" (
    { system, ... }:
    {
      homeProfiles.mkUmbra = mkUmbra;

      homeConfigurations.umbra = mkHome {
        inherit system;
        modules = [
          (self.homeProfiles.mkUmbra {
            username = "ashwin_y";
            homeDirectory = "/home/ashwin_y/.local/share/distrobox/home/umbra";
            containerHost = "unix:///run/host/run/user/1000/podman/podman.sock";
          })
        ];
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
