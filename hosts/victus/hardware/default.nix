{ ... }:
{
  imports = [
    ./boot.nix
    ./filesystem.nix
    ./bluetooth.nix
    ./pipewire.nix
    ./nvidia.nix
    ./power.nix
  ];

  config = {
    hardware.enableRedistributableFirmware = true;
    hardware.uinput.enable = true;
    hardware.enableAllFirmware = true;
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
