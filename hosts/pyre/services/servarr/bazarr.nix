{ config, servarr, ... }:
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
    icon = builtins.fetchurl {
      url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/bazarr.svg";
      sha256 = "06chv4sr3bnz6jbj9h2a0d8s8lx8lp6b5rjd83scg3nbjqfyipa3";
    };
  };
}
