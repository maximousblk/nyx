{
  inputs,
  self,
  mkHome,
  ...
}:
let
  umbra = mkHome {
    name = "umbra";
    module = ./home.nix;
  };
in
{
  flake = {
    homeProfiles.umbra = umbra.mkProfile;

    homeConfigurations.umbra = umbra.mkConfig {
      system = "x86_64-linux";
      username = "ashwin_y";
      homeDirectory = "/home/ashwin_y/.local/share/distrobox/home/umbra";
      containerHost = "unix:///run/host/run/user/1000/podman/podman.sock";
    };

    deploy.nodes.umbra = {
      hostname = "localhost";
      profiles.home = {
        user = "ashwin_y";
        path = inputs.deploy-rs.lib.x86_64-linux.activate.home-manager self.homeConfigurations.umbra;
      };
    };
  };
}
