{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.optx.clanker.stable-diffusion-cpp;
  source = pkgs.fetchFromGitHub {
    owner = "leejet";
    repo = "stable-diffusion.cpp";
    rev = "8caa3f908ae6d4a4bef531e73b9a969f266a3d1f";
    hash = "sha256-voybvJQrG6/Puogf9vBr/3jzHBcl1MnIAsRQtswUw2U=";
    fetchSubmodules = true;
  };
  package =
    {
      cpu = pkgs.stable-diffusion-cpp;
      vulkan = pkgs.stable-diffusion-cpp-vulkan;
      cuda = pkgs.stable-diffusion-cpp-cuda;
    }
    .${cfg.backend}.overrideAttrs
      (_: {
        version = "krea2-8caa3f9";
        inherit source;
        src = source;
      });
  backend =
    {
      cpu = "cpu";
      vulkan = "diffusion=vulkan0,te=vulkan0,vae=vulkan0";
      cuda = "diffusion=cuda0,te=cuda0,vae=cuda0";
    }
    .${cfg.backend};
  optimizationArgs = ''
    --backend '${backend}' \
    --eager-load \
    --mmap \
    --fa \
    --diffusion-fa \
    --diffusion-conv-direct \
    --vae-conv-direct \
    --cache-mode easycache \
    --cache-option threshold=0.1 \
    --cfg-scale 1 \
    --steps 4 \
    --extra-sample-args mu=1.15
  '';
  optimizedCli = pkgs.writeShellApplication {
    name = "sd-cli-krea2-optimized";
    runtimeInputs = [ package ];
    text = ''
      exec ${lib.getExe package} ${optimizationArgs} "$@"
    '';
  };
  optimizedServer = pkgs.writeShellApplication {
    name = "sd-server-krea2-optimized";
    runtimeInputs = [ package ];
    text = ''
      exec ${package}/bin/sd-server ${optimizationArgs} "$@"
    '';
  };
in
{
  options.optx.clanker.stable-diffusion-cpp = {
    enable = lib.mkEnableOption "stable-diffusion.cpp image generation tools";

    backend = lib.mkOption {
      type = lib.types.enum [
        "cpu"
        "vulkan"
        "cuda"
      ];
      default = "cpu";
      description = "Compute backend used by stable-diffusion.cpp.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      package
      optimizedCli
      optimizedServer
    ];
  };
}
