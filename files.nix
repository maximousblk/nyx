{ self, inputs, ... }: {
  imports = [ (inputs.files + "/flake-module.nix") ];

  perSystem =
    {
      pkgs,
      system,
      config,
      ...
    }:
    {
      files = {
        writer.app = true;

        file = {
          ".github/main.svg".source = pkgs.runCommand "main.svg" { } ''
            cp ${self.topology.${system}.config.output}/main.svg $out
          '';

          ".github/network.svg".source = pkgs.runCommand "network.svg" { } ''
            cp ${self.topology.${system}.config.output}/network.svg $out
          '';

          ".github/README.md".text = ''
            # nyx

            ![Topology](main.svg)
          '';
        };
      };
    };
}
