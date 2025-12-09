{
  self,
  inputs,
  withSystem,
  ...
}:
{
  flake = withSystem "x86_64-linux" (
    {
      system,
      pkgs,
      pkgx,
      modx,
      ...
    }:
    {

      nixosConfigurations.victus = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs pkgx modx; };
        modules = [
          ./configuration.nix
          {
            nixpkgs.hostPlatform = system;
            nixpkgs.pkgs = pkgs;
          }
        ];
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
