{ lib, ... }:
{
  imports = [
    ./umbra/parts.nix
    ./victus/parts.nix
  ];

  options = {
    flake = {
      homeConfigurations = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = { };
      };
    };
  };
}
