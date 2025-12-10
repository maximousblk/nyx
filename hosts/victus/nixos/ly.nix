{ ... }:
{
  services.displayManager.ly = {
    enable = true;
    settings = {
      animation = "colormix";
      battery_id = "BAT0";
      bigclock = "en";
      numlock = true;

      auto_login_user = "maximousblk";
      auto_login_session = "niri";
    };
  };

  security.pam.services.ly-autologin = {
    text = ''
      auth       required     pam_permit.so
      account    include      login
      password   include      login
      session    include      login
    '';
  };
}
