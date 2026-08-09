{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.optx.clanker.prime-agent;
  jsonFormat = pkgs.formats.json { };
  primeAgent = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.prime-agent;
in
{
  options.optx.clanker.prime-agent.enable = lib.mkEnableOption "Prime Agent coding agent";

  config = lib.mkIf cfg.enable {
    home.packages = [ primeAgent ];

    home.sessionVariables = {
      # Prime Agent inherits these controls from Pi.
      PI_TELEMETRY = "0";
      PI_SKIP_VERSION_CHECK = "1";
    };

    home.file.".prime/agent/settings.json".source = jsonFormat.generate "prime-agent-settings.json" {
      # Mark onboarding as complete and keep startup output quiet.
      onboardingShown = true;
      quietStartup = true;
      collapseChangelog = true;
      defaultThinkingLevel = "low";
      enabledModels = [
        "openai-codex/gpt-5.6-luna"
        "openai-codex/gpt-5.6-terra"
        "opencode-zen/big-pickle"
        "opencode-zen/laguna-s-2.1-free"
      ];
      mcpServers = lib.mapAttrs (_: server: {
        type = "http";
        inherit (server) url;
      }) (lib.filterAttrs (_: server: server ? url) config.programs.mcp.servers);
    };
  };
}
