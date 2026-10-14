{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.optx.clanker.omp;
  jsonFormat = pkgs.formats.json { };
  yamlFormat = pkgs.formats.yaml { };
  skillsDir = ./skills;
  paseoSkills = "${inputs.paseo}/skills";
  orcaSkills = "${inputs.orca}/skills";
  herdrSkills = pkgs.runCommand "herdr-omp-skills" { } ''
    mkdir -p $out/herdr
    cp ${pkgs.herdr.src}/skills/herdr/SKILL.md $out/herdr/SKILL.md
  '';
  modelPresets = {
    aperture = {
      modelRoles = {
        advisor = "aperture-responses/openai-codex/gpt-6.1-sol:medium";
        commit = "aperture-responses/openai-codex/gpt-6-luna:medium";
        default = "aperture-responses/openai-codex/gpt-5.6-luna:medium";
        designer = "aperture-responses/openai-codex/gpt-6.1-sol:medium";
        frontier = "aperture-responses/openai-codex/gpt-6-astra:medium";
        plan = "aperture-responses/openai-codex/gpt-6.1-sol:medium";
        slow = "aperture-responses/openai-codex/gpt-6.1-sol:medium";
        smol = "aperture-responses/openai-codex/gpt-6-luna:medium";
        task = "aperture-responses/openai-codex/gpt-6-luna:medium";
        tiny = "aperture-responses/openai-codex/gpt-6-luna:medium";
        vision = "aperture-responses/openai-codex/gpt-6-luna:medium";
      };
      defaultThinkingLevel = "medium";
    };
    codex = {
      modelRoles = {
        advisor = "openai-codex/gpt-6.1-sol:medium";
        commit = "openai-codex/gpt-6-luna:medium";
        default = "openai-codex/gpt-5.6-luna:medium";
        designer = "openai-codex/gpt-6.1-sol:medium";
        frontier = "openai-codex/gpt-6-astra:medium";
        plan = "openai-codex/gpt-6.1-sol:medium";
        slow = "openai-codex/gpt-6.1-sol:medium";
        smol = "openai-codex/gpt-6-luna:medium";
        task = "openai-codex/gpt-6-luna:medium";
        tiny = "openai-codex/gpt-6-luna:medium";
        vision = "openai-codex/gpt-6-luna:medium";
      };
      defaultThinkingLevel = "medium";
    };
    claude = {
      modelRoles = {
        advisor = "anthropic/claude-sonnet-5-5:medium";
        commit = "anthropic/claude-haiku-5-5:medium";
        default = "anthropic/claude-haiku-5-5:medium";
        designer = "anthropic/claude-sonnet-5-5:medium";
        frontier = "anthropic/claude-opus-5-5:medium";
        plan = "anthropic/claude-sonnet-5-5:medium";
        slow = "anthropic/claude-sonnet-5-5:medium";
        smol = "anthropic/claude-haiku-5-5:medium";
        task = "anthropic/claude-haiku-5-5:medium";
        tiny = "anthropic/claude-haiku-5-5:medium";
        vision = "anthropic/claude-haiku-5-5:medium";
      };
      defaultThinkingLevel = "medium";
    };
  };
in
{
  options.optx.clanker.omp = {
    enable = lib.mkEnableOption "omp coding agent";
    memory = {
      backend = lib.mkOption {
        type = lib.types.enum [
          "hindsight"
          "mnemopi"
        ];
        default = "mnemopi";
        description = "Memory backend for OMP.";
      };
      hindsightApiUrl = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Hindsight API URL when using the Hindsight memory backend.";
      };
    };
    defaultPreset = lib.mkOption {
      type = lib.types.enum (builtins.attrNames modelPresets);
      default = "aperture";
      description = "Name of the model preset applied as the active OMP roles.";
    };
  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = cfg.memory.backend != "hindsight" || cfg.memory.hindsightApiUrl != null;
        message = "optx.clanker.omp.memory.hindsightApiUrl must be set for the Hindsight backend.";
      }
    ];

    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp ];

    home.sessionVariables.PUPPETEER_EXECUTABLE_PATH = lib.getExe pkgs.brave-origin;

    home.file = lib.mkMerge (
      map (lib.mapAttrs (_: file: file // { force = true; })) [
        {
          ".omp/agent/config.yml".source = yamlFormat.generate "omp-config.yml" (
            {
              async.enabled = true;
              async.pollWaitDuration = "10m";
              autolearn.enabled = true;
              bash.autoBackground.enabled = true;
              bashInterceptor.enabled = true;
              browser.cmux = false;
              browser.enabled = true;
              browser.headless = true;
              computer.enabled = true;
              computer.display = "all";
              computer.maxWidth = 3840;
              computer.maxHeight = 2400;
              commands.enableClaudeProject = false;
              commands.enableClaudeUser = false;
              commands.enableOpencodeProject = false;
              commands.enableOpencodeUser = false;
              compaction.handoffSaveToDisk = true;
              compaction.strategy = "snapcompact";
              cycleOrder = [
                "smol"
                "default"
                "slow"
                "frontier"
              ];
              contextPromotion.enabled = false;
              dev.autoqa = false;
              dev.autoqaConsent = "denied";
              display.cacheMissMarker = true;
              display.shimmer = "kitt";
              edit.fuzzyMatch = false;
              edit.fuzzyThreshold = 0.98;
              edit.mode = "hashline";
              eval.jl = true;
              eval.js = true;
              eval.py = true;
              eval.rb = true;
              features.unexpectedStopDetection = true;
              grep.contextAfter = 5;
              grep.contextBefore = 5;
              github.enabled = true;
              hideThinkingBlock = true;
              images.autoResize = true;
              includeModelInPrompt = false;
              inspect_image.mode = "auto";
              lsp.diagnosticsOnWrite = false;
              lsp.enabled = false;
              lsp.lazy = false;
              marketplace.autoUpdate = "off";
              mcp.enableProjectConfig = false;
              tools.xdev = true;
              tools.xdevDocs = "catalog";
              memory.backend = cfg.memory.backend;
              advisor.enabled = false;
              advisor.syncBacklog = "5";
              personality = "pragmatic";
              plan.defaultOnStartup = false;
              plan.enabled = false;
              readLineNumbers = true;
              secrets.enabled = true;
              showHardwareCursor = true;
              skills.enableClaudeProject = false;
              skills.enableClaudeUser = false;
              skills.enableCodexUser = false;
              skills.enableAgentsProject = false;
              skills.enableAgentsUser = false;
              skills.enablePiProject = false;
              skills.enablePiUser = false;
              skills.includeSkills = [ ];
              startup.checkUpdate = false;
              startup.setupWizard = false;
              symbolPreset = "nerd";
              statusLine.preset = "custom";
              statusLine.separator = "powerline-thin";
              statusLine.compactThinkingLevel = true;
              statusLine.leftSegments = [
                "pi"
                "model"
                "mode"
                "path"
                "git"
                "pr"
                "subagents"
              ];
              statusLine.rightSegments = [
                "session_name"
                "cost"
                "context_pct"
              ];
              task.eager = "default";
              task.enableLsp = false;
              task.maxConcurrency = 4;
              task.maxRecursionDepth = 1;
              task.showResolvedModelBadge = true;
              terminal.showProgress = true;
              terminal.showImages = true;
              todo.eager = "preferred";
              treeFilterMode = "no-tools";
              tui.hyperlinks = "always";
              tui.tight = true;
              worktree.base = "~/projects";

              skills.customDirectories = [
                "${skillsDir}"
                "${herdrSkills}"
                paseoSkills
                orcaSkills
              ];
              extensions = [ "${pkgs.herdr.src}/src/integration/assets/omp/herdr-agent-state.ts" ];
            }
            // {
              modelPresets = modelPresets;
              modelRoles = modelPresets.${cfg.defaultPreset}.modelRoles;
              defaultThinkingLevel = modelPresets.${cfg.defaultPreset}.defaultThinkingLevel;
            }
            // lib.optionalAttrs (cfg.memory.backend == "mnemopi") { mnemopi.scoping = "global"; }
            // lib.optionalAttrs (cfg.memory.backend == "hindsight") {
              hindsight.apiUrl = cfg.memory.hindsightApiUrl;
              hindsight.apiToken = "";
              hindsight.bankId = "aftershoot";
              hindsight.scoping = "global";
              hindsight.autoRecall = true;
              hindsight.autoRetain = true;
              hindsight.retainEveryNTurns = 3;
              hindsight.retainMode = "last-turn";
              hindsight.recallBudget = "mid";
              hindsight.recallContextTurns = 3;
              hindsight.recallTypes = [
                "world"
                "experience"
                "observation"
              ];
              hindsight.mentalModelsEnabled = true;
              hindsight.mentalModelAutoSeed = true;
            }
          );
        }

        {
          ".omp/agent/mcp.json".source = jsonFormat.generate "omp-mcp.json" {
            mcpServers = lib.mapAttrs (
              _: server:
              lib.hm.mcp.transformMcpServer {
                inherit server;
                extraTransforms = [ lib.hm.mcp.addType ];
                exclude = [ "serverUrl" ];
              }
            ) config.programs.mcp.servers;
          };

          ".omp/agent/models.yml".source = yamlFormat.generate "omp-models.yml" {
            providers.aperture-responses = {
              baseUrl = "https://aperture.pony-clownfish.ts.net/v1";
              auth = "none";
              api = "openai-responses";
              discovery.type = "openai-models-list";
            };
          };
        }
      ]
    );
  };
}
