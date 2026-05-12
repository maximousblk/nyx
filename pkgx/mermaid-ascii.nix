{ pkgs, lib }:

pkgs.buildGoModule {
  pname = "mermaid-ascii";
  version = "1.2.0";

  src = pkgs.fetchFromGitHub {
    owner = "AlexanderGrooff";
    repo = "mermaid-ascii";
    rev = "a307c1a69097c9b2fccef050a94198c9b43e2c60";
    hash = "sha256-PbYqYy0jHQb+qvkp+lp/Wlde50dhdg7Ri2eNExXeoQ4=";
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
    license = lib.licenses.mit;
    mainProgram = "mermaid-ascii";
  };
}
