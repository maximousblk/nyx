{ ... }:
{
  services.displayManager = {
    defaultSession = "niri";
    autoLogin = {
      enable = true;
      user = "maximousblk";
    };
    ly = {
      enable = true;
      settings = {
        animation = "colormix";
        battery_id = "BAT0";
        bigclock = "en";
        numlock = true;
      };
    };
  };
}
