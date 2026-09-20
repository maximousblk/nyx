{
  config,
  pkgx,
  servarr,
  ...
}:
let
  port = 6767;
in
{
  nixarr.bazarr = {
    enable = true;
    openFirewall = false;
    port = port;
  };

  optx.tailscale.services.bazarr = {
    serve."https:443" = "http://localhost:${toString port}";
    backends = [ "bazarr.service" ];
  };

  topology.self.services.bazarr = {
    name = "Bazarr";
    info = "Subtitle management";
    icon = pkgx.topology-icons.bazarr;
  };
}
