{ pkgs, ... }:
{
  # OCI Always-Free Ampere instances are reclaimed if CPU stays under 20% AND
  # memory under 20% AND network under 20% for ~7 consecutive days. Keep a
  # small floor of CPU + RAM activity so the box is never a reclaim candidate.
  systemd.services.sustained-load = {
    description = "Maintain small sustained CPU and memory load";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.stress-ng}/bin/stress-ng --taskset package0 --cpu -1 --cpu-load 5 --cpu-load-slice 10 --cpu-method matrixprod --vm 1 --vm-bytes 5% --vm-hang 0";
      Restart = "always";
      RestartSec = "30s";
    };
  };
}
