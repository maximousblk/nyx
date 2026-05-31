{ pkgs }:

pkgs.buildGoModule rec {
  pname = "mermaid-ascii";
  version = "1.2.0+nix.${builtins.substring 0 8 src.rev}";

  src = pkgs.fetchFromGitHub {
    owner = "AlexanderGrooff";
    repo = "mermaid-ascii";
    rev = "6fffb8e2714acab2c4cb41c78894fabbc62cee56";
    hash = "sha256-PhiZecH4hksRMrnfmUIL7O2q0LEXW0LiOQLJ5o0dRs0=";
  };

  vendorHash = "sha256-aB9sbTtlHbptM2995jizGFtSmEIg3i8zWkXz1zzbIek=";

  postPatch = ''
    substituteInPlace cmd/web.go \
      --replace-fail 'r.LoadHTMLGlob("templates/*")' 'r.LoadHTMLGlob("'"$out"'/share/mermaid-ascii/templates/*")' \
      --replace-fail 'r.Static("/static", "./static")' 'r.Static("/static", "'"$out"'/share/mermaid-ascii/static")'
  '';

  postInstall = ''
    install -Dm644 -t $out/share/mermaid-ascii/templates templates/*
    install -Dm644 -t $out/share/mermaid-ascii/static static/*
  '';

  meta = {
    description = "Render Mermaid diagrams as ASCII art";
    homepage = "https://github.com/AlexanderGrooff/mermaid-ascii";
    license = pkgs.lib.licenses.mit;
    mainProgram = "mermaid-ascii";
  };
}
