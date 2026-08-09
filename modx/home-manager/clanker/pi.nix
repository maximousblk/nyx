{
  lib,
  pkgs,
  config,
  pkgx,
  inputs,
  ...
}:
let
  cfg = config.optx.clanker.pi;
  jsonFormat = pkgs.formats.json { };
in
{
  options.optx.clanker.pi = {
    enable = lib.mkEnableOption "pi coding agent";
  };

  config = lib.mkIf cfg.enable {

    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi ];

    home.sessionVariables = {
      PI_TELEMETRY = "0";
      PI_SKIP_VERSION_CHECK = "1";
    };

    home.file = {
      ".pi/agent/settings.json".source = jsonFormat.generate "pi-settings.json" {
        defaultProvider = "openai-codex";
        defaultModel = "gpt-5.6-luna";
        defaultThinkingLevel = "low";
        enabledModels = [
          "openai-codex/gpt-5.6-luna"
          "openai-codex/gpt-5.6-terra"

          "opencode-go/deepseek-v4-flash"

          "opencode-zen/deepseek-v4-flash-free"
        ];
        enableInstallTelemetry = false;
        extensions = [
          "${pkgs.herdr.src}/src/integration/assets/pi/herdr-agent-state.ts"
          pkgx.pi-mcp-adapter.extension
          pkgx.pi-web-access.extension
          pkgx.pi-context-mode.extension
        ];
      };

      ".pi/agent/extensions".source = ./pi-extensions;
    };
  };
}
