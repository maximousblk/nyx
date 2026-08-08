{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.optx.clanker.llama-cpp;
  package = (
    if (cfg.backend == "none") then
      pkgs.llama-cpp
    else if (lib.hasPrefix "Vulkan" cfg.backend) then
      pkgs.llama-cpp-vulkan
    else if (lib.hasPrefix "ROCm" cfg.backend) then
      pkgs.llama-cpp-rocm
    else if (lib.hasPrefix "CUDA" cfg.backend) then
      pkgs.llama-cpp.override { cudaSupport = true; }
    else
      throw "Unsupported llama.cpp backend device: ${cfg.backend}"
  );
in
{
  options.optx.clanker.llama-cpp = {
    enable = lib.mkEnableOption "llama.cpp local LLM service";

    backend = lib.mkOption {
      type = lib.types.str;
      description = "llama.cpp device passed directly to --device; backend package is selected from its prefix.";
    };

    hfRepo = lib.mkOption {
      type = lib.types.str;
      description = "Hugging Face repository containing the base model.";
    };

    hfFile = lib.mkOption {
      type = lib.types.str;
      description = "Base model filename in the Hugging Face repository.";
    };

    mmprojFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional multimodal projector filename.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.llama-cpp = {
      Unit = {
        Description = "llama.cpp HTTP server";
        After = [ "network-online.target" ];
        BindsTo = [ "llama-cpp-proxy.service" ];
        PartOf = [ "llama-cpp-proxy.service" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        ExecStart = lib.escapeShellArgs (
          [
            "${package}/bin/llama-server"
            "--hf-repo"
            cfg.hfRepo
            "--hf-file"
            cfg.hfFile
          ]
          ++ lib.optionals (cfg.mmprojFile != null) [
            "--mmproj"
            cfg.mmprojFile
          ]
          ++ [
            "--host"
            "127.0.0.1"
            "--port"
            "18080"
            "--ctx-size"
            "16384"
            "--parallel"
            "1"
            "--threads"
            "10"
            "--threads-batch"
            "10"
            "--batch-size"
            "256"
            "--ubatch-size"
            "128"
            "--flash-attn"
            "on"
            "--cache-type-k"
            "q4_0"
            "--cache-type-v"
            "q4_0"
            "--poll"
            "0"
            "--temp"
            "0.7"
            "--top-p"
            "0.95"
            "--top-k"
            "20"
            "--min-p"
            "0"
            "--device"
            cfg.backend
            "--n-gpu-layers"
            (if cfg.backend == "none" then "0" else "auto")
          ]
          ++ lib.optionals (cfg.backend != "none") [
            "--fit"
            "on"
          ]
          ++ [
            "--reasoning"
            "on"
            "--jinja"
          ]
        );
        Restart = "on-failure";
        RestartSec = "5s";
        StopWhenUnneeded = true;
      };
    };

    systemd.user.sockets.llama-cpp = {
      Unit.Description = "llama.cpp HTTP socket";
      Socket = {
        ListenStream = 8080;
        Service = "llama-cpp-proxy.service";
      };
      Install.WantedBy = [ "sockets.target" ];
    };

    systemd.user.services.llama-cpp-proxy = {
      Unit = {
        Description = "llama.cpp HTTP socket proxy";
        Requires = [
          "llama-cpp.service"
          "llama-cpp.socket"
        ];
        After = [
          "llama-cpp.service"
          "llama-cpp.socket"
        ];
      };
      Service = {
        ExecStartPre = "${pkgs.wait4x}/bin/wait4x tcp 127.0.0.1:18080";
        ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=20min 127.0.0.1:18080";
        Restart = "on-failure";
      };
    };
  };
}
