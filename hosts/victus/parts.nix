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
      nixosConfigurations.victus = mkNixos {
        inherit system;
        modules = [ ./configuration.nix ];
      };

      deploy.nodes.victus = {
        hostname = "victus";
        sshUser = "maximousblk";
        fastConnection = true;
        profiles.system = {
          user = "root";
          path = inputs.deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.victus;
        };
      };
    }
  );
}
