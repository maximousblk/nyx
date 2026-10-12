{
  config,
  lib,
  pkgx,
  servarr,
  ...
}:
let
  port = 8096;
in
{
  age.secrets.servarr-jellyfin-api-key = {
    mode = "0400";
    generator.script = { pkgs, ... }: ''
      ${pkgs.openssl}/bin/openssl rand -hex 16
    '';
  };
  age.secrets.servarr-jellyfin-admin-password = {
    mode = "0400";
    generator.script = { pkgs, ... }: ''
      ${pkgs.openssl}/bin/openssl rand -hex 24
    '';
  };
  age.secrets.servarr-opensubtitles-password.mode = "0400";
  age.secrets.servarr-opensubtitles-key.mode = "0400";

  nixflix.jellyfin = {
    enable = true;
    apiKey._secret = config.age.secrets.servarr-jellyfin-api-key.path;
    dataDir = "${servarr.state_dir}/jellyfin/data";
    configDir = "${servarr.state_dir}/jellyfin/config";
    cacheDir = "${servarr.state_dir}/jellyfin/cache";
    logDir = "${servarr.state_dir}/jellyfin/log";
    encoding = {
      hardwareAccelerationType = "qsv";
      enableHardwareEncoding = true;
      qsvDevice = "/dev/dri/renderD128";
    };
    users.admin = {
      mutable = false;
      password._secret = config.age.secrets.servarr-jellyfin-admin-password.path;
      policy.isAdministrator = true;
    };
    plugins.subbuzz = {
      enable = true;
      config = {
        EnableOpenSubtitles = true;
        OpenSubUserName = "maximousblk";
        OpenSubPassword._secret = config.age.secrets.servarr-opensubtitles-password.path;
        OpenSubApiKey._secret = config.age.secrets.servarr-opensubtitles-key.path;
        EnablePodnapisiNet = true;
        EnableYifySubtitles = true;
      };
    };
    libraries.Shows = {
      saveLocalMetadata = false;
      metadataSavers = [ ];
      saveTrickplayWithMedia = false;
      saveLyricsWithMedia = false;
      subtitleDownloadLanguages = [ "eng" ];
      subtitleFetcherOrder = [ "subbuzz" ];
      skipSubtitlesIfEmbeddedSubtitlesPresent = true;
      saveSubtitlesWithMedia = false;
      typeOptions = lib.mkForce [
        {
          type = "Series";
          metadataFetchers = [
            "TheMovieDb"
            "The Open Movie Database"
          ];
          metadataFetcherOrder = [
            "TheMovieDb"
            "The Open Movie Database"
          ];
          imageFetchers = [ "TheMovieDb" ];
          imageFetcherOrder = [ "TheMovieDb" ];
        }
        {
          type = "Season";
          metadataFetchers = [
            "TheMovieDb"
            "The Open Movie Database"
          ];
          metadataFetcherOrder = [
            "TheMovieDb"
            "The Open Movie Database"
          ];
          imageFetchers = [ "TheMovieDb" ];
          imageFetcherOrder = [ "TheMovieDb" ];
        }
        {
          type = "Episode";
          metadataFetchers = [
            "TheMovieDb"
            "The Open Movie Database"
          ];
          metadataFetcherOrder = [
            "TheMovieDb"
            "The Open Movie Database"
          ];
          imageFetchers = [ "TheMovieDb" ];
          imageFetcherOrder = [ "TheMovieDb" ];
        }
      ];
    };
    libraries.Movies = {
      saveLocalMetadata = false;
      metadataSavers = [ ];
      saveTrickplayWithMedia = false;
      saveLyricsWithMedia = false;
      subtitleDownloadLanguages = [ "eng" ];
      subtitleFetcherOrder = [ "subbuzz" ];
      skipSubtitlesIfEmbeddedSubtitlesPresent = true;
      saveSubtitlesWithMedia = false;
      typeOptions = lib.mkForce [
        {
          type = "Movie";
          metadataFetchers = [
            "TheMovieDb"
            "The Open Movie Database"
          ];
          metadataFetcherOrder = [
            "TheMovieDb"
            "The Open Movie Database"
          ];
          imageFetchers = [
            "TheMovieDb"
            "The Open Movie Database"
          ];
          imageFetcherOrder = [
            "TheMovieDb"
            "The Open Movie Database"
          ];
        }
      ];
    };
    libraries.Anime = {
      saveLocalMetadata = false;
      metadataSavers = [ ];
      saveTrickplayWithMedia = false;
      saveLyricsWithMedia = false;
      subtitleDownloadLanguages = [ "eng" ];
      subtitleFetcherOrder = [ "subbuzz" ];
      skipSubtitlesIfEmbeddedSubtitlesPresent = true;
      saveSubtitlesWithMedia = false;
    };
  };

  users.users.jellyfin.extraGroups = [
    "video"
    "render"
  ];

  optx.tailscale.services.jellyfin = {
    serve."https:443" = "http://localhost:${toString port}";
    backends = [ "jellyfin.service" ];
  };

  topology.self.services.jellyfin = {
    name = "Jellyfin";
    info = "Media server";
    icon = pkgx.topology-icons.jellyfin;
  };
}
