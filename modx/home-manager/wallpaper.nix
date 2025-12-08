{ lib, config, ... }:
let
  cfg = config.optx.wallpapers;
in
{
  options.optx.wallpapers = {
    enable = lib.mkEnableOption "centralized wallpaper management";

    package = lib.mkOption {
      type = lib.types.package;
      description = "The package containing the wallpaper images.";
    };

    paths = {
      collection = lib.mkOption {
        type = lib.types.path;
        readOnly = true;
        default = "${config.xdg.dataHome}/wallpapers";
        description = "Path to the directory containing all wallpapers.";
      };

      current = lib.mkOption {
        type = lib.types.path;
        readOnly = true;
        default = "${config.xdg.stateHome}/current_wallpaper";
        description = "Path where the active wallpaper symlink should exist.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.dataFile."wallpapers".source = cfg.package;
  };
}
