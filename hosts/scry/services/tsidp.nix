{ pkgx, pkgs, ... }:
let
  tsidp = (pkgs.tsidp.override { buildGoModule = pkgs.buildGoModule.override { go = pkgs.go_1_27; }; }).overrideAttrs (_old: {
    version = "0.0.18";
    src = pkgs.fetchFromGitHub {
      owner = "tailscale";
      repo = "tsidp";
      tag = "v0.0.18";
      hash = "sha256-oL+WH5iFVRd0erh3KfJrvUMIpZraomHoRzo5sh3duu0=";
    };
    vendorHash = "sha256-X3o71xgGBFJM3Sspb+223NYsDwJ3jf+9lCWQxS6JDA8=";
  });
in
{
  services.tsidp = {
    enable = true;
    package = tsidp;
    settings.enableSts = true;
  };

  topology.self.services.tsidp = {
    name = "tsidp";
    info = "Tailnet OIDC identity provider";
    icon = pkgx.topology-icons.tailscale;
  };
}
