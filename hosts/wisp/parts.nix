{
  inputs,
  mkNixos,
  self,
  withSystem,
  ...
}:
{
  flake = withSystem "aarch64-linux" (
    { system, ... }: {
      nixosConfigurations.wisp = mkNixos {
        inherit system;
        modules = [
          "${inputs.nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
          "${inputs.nixpkgs}/nixos/modules/virtualisation/lxc-image-metadata.nix"
          ./configuration.nix
          { system.nixos.label = "wisp-lxc-${inputs.nixpkgs.lib.version}"; }
        ];
      };

      deploy.nodes.wisp = {
        hostname = "wisp";
        sshUser = "root";
        remoteBuild = false;
        profiles.system = {
          user = "root";
          path = inputs.deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.wisp;
        };
      };
    }
  );
}
