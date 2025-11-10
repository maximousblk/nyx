{ ... }:
{
  services.displayManager.ly.enable = true;
  services.displayManager.ly.settings = {
    animation = "colormix";
    battery_id = "BAT0";
    bigclock = "en";
    numlock = true;

    auto_login_session = "niri";
    auto_login_user = "maximousblk";
    auto_login_service = "ly-autologin";
  };
}
