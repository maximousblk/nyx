{ config, ... }:
{
  config = {
    services.tlp.enable = true;
  };

  assertions = [
    {
      assertion = !config.services.tlp.enable || !config.services.power-profiles-daemon.enable;
      message = "services.tlp.enable and services.power-profiles-daemon.enable are mutually exclusive.";
    }
  ];
}
