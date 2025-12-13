{ ... }:
{
  programs.waybar = {
    enable = false;
    systemd = {
      enable = true;
      target = "niri-session.target";
    };
    settings = builtins.fromJSON (builtins.readFile ./waybar.config.json);
    style = builtins.readFile ./waybar.style.css;
  };
}
