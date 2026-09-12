{
  config,
  lib,
  pkgs,
  ...
}:
let
  exports = lib.mapAttrsToList (destination: file: ''
    ${pkgs.coreutils}/bin/install -Dm644 \
      ${lib.escapeShellArg file.text} \
      ${lib.escapeShellArg destination}
    echo "Installed Windows file: ${destination}"
  '') config.windowsFiles;
in
{
  options.windowsFiles = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options.text = lib.mkOption {
          type = lib.types.either lib.types.str lib.types.package;
          description = "Nix store file to materialize at this Windows path.";
        };
      }
    );
    default = { };
    description = "Nix store files materialized into the mounted Windows filesystem.";
  };

  config = lib.mkIf (config.windowsFiles != { }) { system.activationScripts.windowsFiles = lib.concatStringsSep "\n" exports; };
}
