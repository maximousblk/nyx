{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    deploy-rs
    ghostty
    helix
    fastfetch

    rose-pine-cursor

    rar
    unrar
    ncdu

    cudaPackages.cudatoolkit
  ];
}
