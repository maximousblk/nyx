{ pkgx, ... }: {
  services.tsidp = {
    enable = true;
    settings.enableSts = true;
  };

  topology.self.services.tsidp = {
    name = "tsidp";
    info = "Tailnet OIDC identity provider";
    icon = pkgx.topology-icons.tailscale;
  };
}
