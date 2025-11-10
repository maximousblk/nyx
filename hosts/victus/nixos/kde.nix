# KDE
{ ... }:
{
  displayManager.sddm.enable = true;
  displayManager.sddm.wayland.enable = true;
  displayManager.sddm.settings.General.DisplayServer = "wayland";
  desktopManager.plasma6.enable = true;
}
