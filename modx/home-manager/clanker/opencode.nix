{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.optx.clanker.opencode;
  opencode2 = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode2;
in
{
  options.optx.clanker.opencode.enable = lib.mkEnableOption "opencode with MCP integration";

  config = lib.mkIf cfg.enable {
    home.packages = [ opencode2 ];

    programs.opencode = {
      enable = true;
      package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
      enableMcpIntegration = true;
      tui.theme = "system";
      settings = {
        autoupdate = false;
        share = "disabled";
        default_agent = "plan";
        snapshot = false;
        model = "openai/gpt-5.5";
        small_model = "openai/gpt-5.4-mini";
        lsp.rust.disabled = true;
        watcher.ignore = [
          "node_modules/**"
          "dist/**"
          ".git/**"
          "*.sqlite"
        ];
        permission = {
          "*" = "ask";
          read = "allow";
          glob = "allow";
          grep = "allow";
          list = "allow";
          lsp = "allow";
          webfetch = "allow";
          todoread = "allow";
          todowrite = "allow";
          task = "allow";
        };
        agent = {
          plan.permission = {
            edit = "ask";
            bash = "ask";
          };
          build.permission = {
            edit = "ask";
            bash = "ask";
          };
        };
      };
    };

    programs.opencode.settings.provider.ollama = lib.mkIf config.optx.clanker.ollama.enable {
      npm = "@ai-sdk/openai-compatible";
      name = "Ollama";
      options.baseURL = "http://localhost:11434/v1";
      models."gemma4:26b".name = "Gemma 4";
    };
  };
}
