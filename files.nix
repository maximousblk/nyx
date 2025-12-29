{ self, inputs, ... }:
{
  imports = [ inputs.files.flakeModules.default ];

  perSystem =
    {
      pkgs,
      system,
      config,
      ...
    }:
    {
      files.files = [
        {
          path_ = ".github/main.svg";
          drv = pkgs.runCommand "main.svg" { } ''
            cp ${self.topology.${system}.config.output}/main.svg $out
          '';
        }
        {
          path_ = ".github/network.svg";
          drv = pkgs.runCommand "network.svg" { } ''
            cp ${self.topology.${system}.config.output}/network.svg $out
          '';
        }
        {
          path_ = ".github/README.md";
          drv = pkgs.writeText "README.md" ''
            # nyx

            ![Topology](main.svg)
          '';
        }
      ];

      packages.write-files = config.files.writer.drv;
    };
}
