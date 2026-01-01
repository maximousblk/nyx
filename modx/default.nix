{
  nixos = {
    tailscale-services = ./nixos/tailscale-services.nix;
  };

  hm = {
    wallpaper = ./home-manager/wallpaper.nix;
  };

  common = { };
}
