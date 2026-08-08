{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.optx.clanker.stable-diffusion-cpp;
  package =
    {
      cpu = pkgs.stable-diffusion-cpp;
      vulkan0 = pkgs.stable-diffusion-cpp-vulkan;
      cuda0 = pkgs.stable-diffusion-cpp-cuda;
    }
    .${cfg.backend};
in
{
  options.optx.clanker.stable-diffusion-cpp = {
    enable = lib.mkEnableOption "stable-diffusion.cpp image generation tools";

    backend = lib.mkOption {
      type = lib.types.enum [
        "cpu"
        "vulkan0"
        "cuda0"
      ];
      default = "cpu";
      description = "stable-diffusion.cpp backend device used for inference.";
    };

    modelsDir = lib.mkOption {
      type = lib.types.str;
      default = "%h/models/krea2";
      description = "Directory containing the stable-diffusion.cpp models.";
    };

    diffusionModel = lib.mkOption {
      type = lib.types.str;
      description = "Diffusion model filename.";
    };

    llmModel = lib.mkOption {
      type = lib.types.str;
      description = "Text encoder model filename.";
    };

    vaeModel = lib.mkOption {
      type = lib.types.str;
      description = "VAE model filename.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ package ];
    systemd.user.services.sd-server = {
      Unit = {
        Description = "stable-diffusion.cpp HTTP server";
        BindsTo = [ "sd-server-proxy.service" ];
        PartOf = [ "sd-server-proxy.service" ];
      };
      Service = {
        WorkingDirectory = cfg.modelsDir;
        ExecStart = lib.escapeShellArgs [
          "${package}/bin/sd-server"
          "--listen-ip"
          "127.0.0.1"
          "--listen-port"
          "11234"
          "--backend"
          cfg.backend
          "--offload-to-cpu"
          "--max-vram"
          "-0.5"
          "--stream-layers"
          "--fa"
          "--diffusion-fa"
          "--diffusion-conv-direct"
          "--vae-conv-direct"
          "--diffusion-model"
          "./${cfg.diffusionModel}"
          "--llm"
          "./${cfg.llmModel}"
          "--vae"
          "./${cfg.vaeModel}"
          "--lora-model-dir"
          "."
        ];
        Restart = "on-failure";
        StopWhenUnneeded = true;
      };
    };

    systemd.user.sockets.sd-server = {
      Unit.Description = "stable-diffusion.cpp HTTP socket";
      Socket = {
        ListenStream = 1234;
        Service = "sd-server-proxy.service";
      };
      Install.WantedBy = [ "sockets.target" ];
    };

    systemd.user.services.sd-server-proxy = {
      Unit = {
        Description = "stable-diffusion.cpp HTTP socket proxy";
        Requires = [
          "sd-server.service"
          "sd-server.socket"
        ];
        After = [
          "sd-server.service"
          "sd-server.socket"
        ];
      };
      Service = {
        ExecStartPre = "${pkgs.wait4x}/bin/wait4x tcp 127.0.0.1:11234";
        ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=20min 127.0.0.1:11234";
        Restart = "on-failure";
      };
    };
  };
}
