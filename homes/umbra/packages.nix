{ pkgs, ... }:
{
  home.packages = with pkgs; [
    argocd
    bat
    btop
    bun
    cmake
    conan
    docker
    docker-compose
    duckdb
    exempi
    exiftool
    exiv2
    eza
    fd
    fenix.stable.toolchain
    fzf
    gcc
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
    jq
    jwt-cli
    kubernetes-helm
    libgcc
    libva
    libva-utils
    mesa
    micro
    mongosh
    mpv
    neovim
    nerd-fonts.jetbrains-mono
    nil
    nixd
    nixfmt-rfc-style
    nodejs_24
    opencode
    openssl.dev
    opentofu
    packer
    pkg-config
    podman
    podman-compose
    ripgrep
    sops
    ssh-to-age
    # terragrunt
    tmux
    trufflehog
    uv
    uxplay
    winetricks
    wineWowPackages.waylandFull
    wl-clipboard-rs
    yarn
    yq
    zoxide

    (python312.withPackages (pypkgs: with pypkgs; [ exiv2 ]))
    (ruby.withPackages (ps: with ps; [ license_finder ]))

    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.kubectl
      google-cloud-sdk.components.gke-gcloud-auth-plugin
      google-cloud-sdk.components.package-go-module
    ])
  ];
}
