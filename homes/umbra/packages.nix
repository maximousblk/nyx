{ pkgs, ... }:
{
  home.packages = with pkgs; [
    argocd
    bat
    btop
    bun
    conan
    docker
    docker-compose
    duckdb
    exempi
    exiftool
    exiv2
    eza
    fd
    fzf
    gh
    git
    glibcLocales
    gnumake
    go
    gopls
    gping
    grafana-alloy
    gum
    intel-media-driver
    kubernetes-helm
    libgcc
    libva
    libva-utils
    mesa
    micro
    mpv
    neovim
    nerd-fonts.jetbrains-mono
    nil
    nixd
    nixfmt-rfc-style
    opencode
    opentofu
    packer
    podman
    podman-compose
    ripgrep
    terragrunt
    tmux
    trufflehog
    uv
    uxplay
    winetricks
    wineWowPackages.waylandFull
    yarn
    zoxide
    (ollama.override { acceleration = false; })
    (python312.withPackages (pypkgs: with pypkgs; [ exiv2 ]))
    nodejs_24
    (ruby.withPackages (ps: with ps; [ license_finder ]))

    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.kubectl
      google-cloud-sdk.components.gke-gcloud-auth-plugin
      google-cloud-sdk.components.package-go-module
    ])
  ];
}
