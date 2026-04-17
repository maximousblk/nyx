{ pkgs, ... }:
{
  system.fsPackages = [ pkgs.mergerfs ];

  programs.fuse.userAllowOther = true;

  fileSystems."/mnt/data" = {
    depends = [
      "/mnt/disk1"
      "/mnt/disk2"
    ];
    device = "/mnt/disk1:/mnt/disk2";
    fsType = "fuse.mergerfs";
    options = [
      "defaults"
      "nofail"
      "allow_other"
      "use_ino"
      "cache.files=partial"
      "dropcacheonclose=true"
      "moveonenospc=true"
      "category.create=epmfs"
      "minfreespace=50G"
      "fsname=mergerfs"
    ];
  };

  services.snapraid = {
    enable = true;
    dataDisks = {
      d1 = "/mnt/disk1/";
      d2 = "/mnt/disk2/";
    };
    parityFiles = [ "/mnt/parity1/snapraid.parity" ];

    # Removed the parity disk from content files for performance
    contentFiles = [
      "/var/lib/snapraid.content"
      "/mnt/disk1/snapraid.content"
      "/mnt/disk2/snapraid.content"
    ];
    exclude = [
      "*.unrecoverable"
      "*.part"
      "*.tmp"
      "/tmp/"
      "/lost+found/"
      "/.Trash-*/"
      "/.recycle/"
      "/@eaDir/"
    ];

    sync.interval = "01:00";
    scrub = {
      interval = "Sun *-*-* 06:00:00";
      plan = 12;
      olderThan = 14;
    };

    extraConfig = ''
      nohidden
    '';
  };
}
