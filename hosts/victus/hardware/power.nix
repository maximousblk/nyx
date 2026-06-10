{ ... }: {
  config = {

    powerManagement.enable = true;

    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;

    services.logind = {
      settings = {
        Login.HandleLidSwitchDocked = "ignore";
        Login.HandleLidSwitchExternalPower = "lock";
        Login.HandleLidSwitch = "poweroff";
      };
    };

    services.thermald.enable = true;
  };
}
