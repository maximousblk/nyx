{
  config,
  lib,
  pkgs,
  servarr,
  ...
}:
let
  port = 9091;
  torrentBackupDir = "${servarr.media_dir}/torrents/.backup";

  # Script to copy .torrent file when added
  copyTorrentScript = pkgs.writeShellScript "copy-torrent" ''
    # TR_TORRENT_NAME, TR_TORRENT_HASH, TR_TORRENT_DIR set by Transmission
    if [ -n "$TR_TORRENT_HASH" ]; then
      torrentDir="${servarr.state_dir}/transmission/.config/transmission-daemon/torrents"
      src="$torrentDir/$TR_TORRENT_HASH.torrent"
      
      # For .torrent files (not magnets)
      if [ -f "$src" ]; then
        cp "$src" "${torrentBackupDir}/$TR_TORRENT_NAME.torrent" 2>/dev/null || true
      fi
      
      # For magnet links, copy the .magnet file
      src_magnet="$torrentDir/$TR_TORRENT_HASH.magnet"
      if [ -f "$src_magnet" ]; then
        cp "$src_magnet" "${torrentBackupDir}/$TR_TORRENT_NAME.magnet" 2>/dev/null || true
      fi
    fi
  '';
in
{
  # Create backup directory for .torrent files
  systemd.tmpfiles.settings."10-transmission-backup" = {
    "${torrentBackupDir}".d = {
      mode = "0775";
      user = "transmission";
      group = "media";
    };
  };

  nixarr.transmission = {
    enable = true;
    openFirewall = false;
    peerPort = 51413;
    uiPort = port;
    flood.enable = true;
    messageLevel = "warn";
    extraSettings = {
      ratio-limit-enabled = true;
      ratio-limit = 0;
      idle-seeding-limit-enabled = true;
      idle-seeding-limit = 1;

      # Copy .torrent files when added
      script-torrent-added-enabled = true;
      script-torrent-added-filename = "${copyTorrentScript}";
    };
  };

  # Override nixpkgs' restrictive umask (0066) to allow group access for *arr apps
  # The default is for RootDirectory= sandboxing; we need media group to access files
  systemd.services.transmission.serviceConfig.UMask = lib.mkForce "0002";

  optx.tailscale.services.transmission = {
    target = "http://localhost:${toString port}";
    port = 443;
    protocol = "https";
    unitConfig = {
      After = [ "transmission.service" ];
      BindsTo = [ "transmission.service" ];
    };
    installConfig = {
      WantedBy = [ "transmission.service" ];
    };
  };

  topology.self.services.transmission = {
    name = "Transmission";
    info = "Torrent client";
    icon = "services.transmission";
  };
}
