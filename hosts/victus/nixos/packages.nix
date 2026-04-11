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

  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [ ];
}
