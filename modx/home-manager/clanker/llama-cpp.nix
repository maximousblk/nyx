{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.optx.clanker.llama-cpp;
  llama-cpp = (pkgs.llama-cpp.override { vulkanSupport = true; }).overrideAttrs (old: {
    pname = "llama-cpp-prism";
    version = "10064";
    src = pkgs.fetchFromGitHub {
      owner = "PrismML-Eng";
      repo = "llama.cpp";
      rev = "9fcaed763ccda38ea81068ad9d7f991aaddca451";
      hash = "sha256-Ir3Rf3c5FqvaKu1CSR7hPi98s3gtJ/ZSD2BWaDraHqQ=";
    };
    npmDepsHash = "sha256-pjdbI6NcZRlJVd62xhgbLhWrwFYwgsIwjORqvo1+VD8=";
    preConfigure = ''
      echo 10064 > COMMIT
      ${old.preConfigure}
    '';
  });
  serverArgs = [
    "${llama-cpp}/bin/llama-server"
    "--hf-repo"
    "dealignai/Bonsai-27b-Ternary-CRACK-GGUF"
    "--hf-file"
    "Bonsai-27b-Ternary-CRACK-Q2_0.gguf"
    "--mmproj-url"
    "https://huggingface.co/dealignai/Bonsai-27b-Ternary-CRACK-GGUF/resolve/main/mmproj-Bonsai-27b-Ternary-CRACK-F16.gguf"
    "--host"
    "0.0.0.0"
    "--port"
    "8080"
    "--ctx-size"
    "4096"
    "--temp"
    "0.7"
    "--top-p"
    "0.95"
    "--top-k"
    "20"
    "--min-p"
    "0"
    "--n-gpu-layers"
    "99"
    "--image-max-tokens"
    "1024"
    "--jinja"
  ];
in
{
  options.optx.clanker.llama-cpp.enable = lib.mkEnableOption "llama.cpp local LLM service";

  config = lib.mkIf cfg.enable {
    systemd.user.services.llama-cpp = {
      Unit = {
        Description = "llama.cpp HTTP server";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Install.WantedBy = [ "default.target" ];
      Service = {
        ExecStart = lib.escapeShellArgs serverArgs;
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
