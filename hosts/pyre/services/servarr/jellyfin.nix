{
  config,
  inputs,
  pkgs,
  servarr,
  ...
}:
let
  port = 8096;
  nixarrPySource = pkgs.applyPatches {
    name = "nixarr-py-jellyfin-12";
    src = "${inputs.nixarr}/nixarr/lib/nixarr-py";
    patches = [ ./nixarr-jellyfin-12.patch ];
  };
in
{
  nixarr.jellyfin = {
    enable = true;
    openFirewall = false;
  };

  # The pinned Nixarr schema hash table predates Jellyfin 12.
  nixarr.nixarr-py.package = pkgs.callPackage nixarrPySource { jellyfin = config.nixarr.jellyfin.package; };

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
    icon = "services.jellyfin";
  };
}
