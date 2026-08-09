{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.optx.clanker.claude;
in
{
  options.optx.clanker.claude.enable = lib.mkEnableOption "claude-code with MCP integration";

  config = lib.mkIf cfg.enable {
    home.sessionVariables.CLAUDE_CODE_NO_FLICKER = "1";
    programs.claude-code = {
      enable = true;
      package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
      enableMcpIntegration = true;
      settings = {
        model = "sonnet";
        effortLevel = "low";
        permissions = {
          allow = [ ];
          defaultMode = "plan";
        };
      };
    };
  };
}
