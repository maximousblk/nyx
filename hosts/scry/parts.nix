{
  self,
  inputs,
  mkNixos,
  withSystem,
  ...
}:
{
  flake = withSystem "aarch64-linux" (
    { system, ... }:
    {
      nixosConfigurations.scry = mkNixos {
        inherit system;
        modules = [ ./configuration.nix ];
      };

      deploy.nodes.scry = {
        hostname = "scry";
        sshUser = "root";
        remoteBuild = true;
        profiles.system = {
          user = "root";
          path = inputs.deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.scry;
        };
      };
    }
  );
}
