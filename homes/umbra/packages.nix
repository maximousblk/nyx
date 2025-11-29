{ pkgs, ... }:
{
  home.packages = with pkgs; [
    git
    gnumake
    bat
    btop
    eza
    fd
    fzf
    gping
    gum
    micro
    neovim
    ripgrep
    tmux
    zoxide

    nerd-fonts.jetbrains-mono

    (pkgs.ollama.override { acceleration = false; })

    bun
    go
    gopls
    nodejs_20
    libgcc

    (pkgs.python312.withPackages (
      pypkgs: with pypkgs; [
        exiv2
      ]
    ))

    uv
    yarn
    conan

    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.kubectl
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
    grafana-alloy
    argocd
    duckdb

    podman
    podman-compose
    docker
    docker-compose

    kubernetes-helm
    opentofu
    packer
    terragrunt

    trufflehog
    # surrealist # Temporarily disabled due to hash mismatch

    exiftool
    exiv2
    exempi

    glibcLocales
    intel-media-driver
    libva
    libva-utils
    mesa
    mpv
    wineWowPackages.waylandFull
    winetricks
    uxplay

    github-copilot-cli

    nixd
    opencode
    nil
    nixfmt-rfc-style

    (ruby.withPackages (ps: with ps; [ license_finder ]))
  ];
}
