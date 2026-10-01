{
  self,
  inputs,
  mkNixos,
  withSystem,
  ...
}:
{
  flake = {
    secretFiles = [
      ".secrets/erebus/manual/tailscale-operator-k8s.age"
      ".secrets/erebus/manual/openbao-static-seal.age"
    ];
  }
  // withSystem "aarch64-linux" (
    { system, ... }: {
      nixosConfigurations.erebus = mkNixos {
        inherit system;
        modules = [ ./configuration.nix ];
      };

      packages.${system}.erebus-sd-image = self.nixosConfigurations.erebus.config.system.build.sdImage;

      deploy.nodes.erebus = {
        hostname = "erebus";
        sshUser = "root";
        remoteBuild = false;
        profiles.system = {
          user = "root";
          path = inputs.deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.erebus;
        };
      };
    }
  );
}
