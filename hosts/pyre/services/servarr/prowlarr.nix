{ config, servarr, ... }:
let
  port = 9696;
in
{
  age.secrets.servarr-prowlarr-api-key = {
    mode = "0400";
    generator.script = { pkgs, ... }: ''
      ${pkgs.openssl}/bin/openssl rand -hex 16
    '';
  };
  age.secrets.servarr-rutracker-username.mode = "0400";
  age.secrets.servarr-rutracker-password.mode = "0400";

  nixflix.prowlarr = {
    enable = true;
    openFirewall = false;
    config.apiKey._secret = config.age.secrets.servarr-prowlarr-api-key.path;
    config.hostConfig = {
      inherit port;
      bindAddress = "127.0.0.1";
      authenticationMethod = "external";
      username = null;
      password = null;
    };
    config.indexers = [
      {
        name = "1337x";
        tags = [ "all" ];
      }
      {
        name = "LimeTorrents";
        tags = [ "all" ];
      }
      {
        name = "Nyaa.si";
        tags = [ "all" ];
      }
      {
        name = "SubsPlease";
        tags = [ "all" ];
      }
      {
        name = "The Pirate Bay";
        tags = [ "all" ];
      }
      {
        name = "YTS";
        tags = [ "all" ];
      }
      {
        name = "RuTracker.org";
        tags = [ "all" ];
        username._secret = config.age.secrets.servarr-rutracker-username.path;
        password._secret = config.age.secrets.servarr-rutracker-password.path;
      }
    ];
    config.indexerProxies = [
      {
        name = "FlareSolverr";
        host = "http://scry:8191";
        requestTimeout = 160;
        tags = [
          "all"
          "cloudflare"
        ];
      }
      {
        name = "Socks5";
        host = "scry";
        port = 1080;
        tags = [ "all" ];
      }
    ];
  };

  optx.tailscale.services.prowlarr = {
    serve."https:443" = "http://localhost:${toString port}";
    backends = [ "prowlarr.service" ];
  };

  topology.self.services.prowlarr = {
    name = "Prowlarr";
    info = "Indexer manager";
    icon = "services.prowlarr";
  };
}
