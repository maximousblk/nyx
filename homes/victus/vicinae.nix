{ ... }:
{
  services.vicinae = {
    enable = true;
    systemd = {
      enable = true;
      autoStart = true;
    };
    settings = {
      favicon_service = "twenty";
      pop_to_root_on_close = true;

      font = {
        rendering = "native";
        normal = {
          family = "IoskeleyMono Nerd Font";
          size = 12;
        };
      };

      rootSearch.searchFiles = false;

      layer_shell = false;
      launcher_window = {
        corner_radius = 10;
      };
    };
  };
}
