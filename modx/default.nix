{
  nixos = {
    opentelemetry-agent = ./nixos/opentelemetry-agent.nix;
    secrets = ./nixos/secrets.nix;
    tailscale-services = ./nixos/tailscale-services.nix;
  };

  hm = {
    clanker = ./home-manager/clanker.nix;
    wallpaper = ./home-manager/wallpaper.nix;
  };

  common = { };
}
