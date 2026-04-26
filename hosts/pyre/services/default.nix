{ ... }:
{
  imports = [
    ./dns.nix
    ./ssh.nix
    ./tailscale.nix
    ./opentelemetry.nix
    ./nfs.nix
    ./servarr
  ];
}
