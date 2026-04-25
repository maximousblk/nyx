{
  nixos = {
    secrets = ./nixos/secrets.nix;
    tailscale-services = ./nixos/tailscale-services.nix;
  };

  hm = {
    clanker = ./home-manager/clanker.nix;
    wallpaper = ./home-manager/wallpaper.nix;
  };

  common = { };
}
