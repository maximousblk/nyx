{
  nixos = {
    opentelemetry-agent = ./nixos/opentelemetry-agent.nix;
    secrets = ./nixos/secrets.nix;
    tailscale-services = ./nixos/tailscale-services.nix;
    windows-files = ./nixos/windows-files.nix;
  };

  hm = {
    clanker = ./home-manager/clanker;
    wallpaper = ./home-manager/wallpaper.nix;
  };

  common = { };
}
