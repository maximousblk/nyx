{ ... }:
{
  imports = [
    ./ssh.nix
    ./tailscale.nix
    ./opentelemetry.nix
    ./nfs.nix
    ./servarr
  ];
}
