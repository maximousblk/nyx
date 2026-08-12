{ ... }: {
  services.tsidp = {
    enable = true;
    settings.enableSts = true;
  };

  topology.self.services.tsidp = {
    name = "tsidp";
    info = "Tailnet OIDC identity provider";
    icon = builtins.fetchurl {
      url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/tailscale-light.svg";
      sha256 = "sha256-H8c/u1bm7WNLnA2T5Gi6Yow3S5fg6KXagxfMDB4jWuk=";
    };
  };
}
