{ config, servarr, ... }:
let
  port = 5055;
in
{
  age.secrets.servarr-seerr-api-key = {
    mode = "0400";
    generator.script = { pkgs, ... }: ''
      ${pkgs.openssl}/bin/openssl rand -hex 16
    '';
  };
  nixflix.seerr = {
    enable = true;
    openFirewall = false;
    inherit port;
    dataDir = "${servarr.state_dir}/seerr";
    apiKey._secret = config.age.secrets.servarr-seerr-api-key.path;
    radarr.Radarr = {
      port = 7878;
      apiKey._secret = config.age.secrets.servarr-radarr-api-key.path;
      activeProfileName = "[SQP] SQP-1 (1080p)";
      activeDirectory = "${servarr.media_dir}/library/movies";
      isDefault = true;
    };
    sonarr = {
      "Sonarr TV" = {
        port = 8989;
        apiKey._secret = config.age.secrets.servarr-sonarr-api-key.path;
        activeProfileName = "WEB-1080p (Alternative)";
        activeAnimeProfileName = "WEB-1080p (Alternative)";
        activeDirectory = "${servarr.media_dir}/library/shows";
        activeAnimeDirectory = "${servarr.media_dir}/library/shows";
        isDefault = true;
      };
      "Sonarr Anime" = {
        port = 8990;
        apiKey._secret = config.age.secrets.servarr-sonarr-anime-api-key.path;
        activeProfileName = "[Anime] Remux-1080p";
        activeAnimeProfileName = "[Anime] Remux-1080p";
        activeDirectory = "${servarr.media_dir}/library/anime";
        activeAnimeDirectory = "${servarr.media_dir}/library/anime";
        isDefault = false;
      };
    };
  };

  optx.tailscale.services.seerr = {
    serve."https:443" = "http://localhost:${toString port}";
    backends = [ "seerr.service" ];
  };

  topology.self.services.seerr = {
    name = "Seerr";
    info = "Media request management";
    icon = "services.seerr";
  };
}
