{
  self,
  inputs,
  mkNixos,
  withSystem,
  ...
}:
{
  flake = withSystem "x86_64-linux" (
    { system, ... }:
    {
      nixosConfigurations.cairn = mkNixos {
        inherit system;
        modules = [ ./configuration.nix ];
      };

      deploy.nodes.cairn = {
        hostname = "cairn";
        sshUser = "root";
        fastConnection = true;
        profiles.system = {
          user = "root";
          path = inputs.deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.cairn;
        };
      };
    }
  );
}
