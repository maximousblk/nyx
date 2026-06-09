import { completeSimple } from "@earendil-works/pi-ai";
import type {
  ExtensionAPI,
  ExtensionCommandContext,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

type TextBlock = { readonly type: "text"; readonly text: string };

type SessionEntry = {
  readonly type: string;
  readonly message: {
    readonly role: string;
    readonly content: unknown;
  };
};

// ---------------------------------------------------------------------------
// Guard
// ---------------------------------------------------------------------------

function isSessionEntry(value: unknown): value is SessionEntry {
  if (value === null || value === undefined || typeof value !== "object") {
    return false;
  }
  const rec = value as Record<string, unknown>;
  if (typeof rec.type !== "string") {
    return false;
  }
  const msg = rec.message;
  if (msg === null || msg === undefined || typeof msg !== "object") {
    return false;
  }
  const msgRec = msg as Record<string, unknown>;
  return typeof msgRec.role === "string";
}

// ---------------------------------------------------------------------------
// Message extraction
// ---------------------------------------------------------------------------

function extractUserText(content: unknown): string {
  if (typeof content === "string") {
    return content;
  }
  if (!Array.isArray(content)) {
    return "";
  }
  const lines: string[] = [];
  for (let i = 0; i < content.length; i++) {
    const block = content[i] as Record<string, unknown>;
    if (block.type === "text" && typeof block.text === "string") {
      lines.push(block.text as string);
    }
  }
  return lines.join("\n");
}

function getLastUserMessages(ctx: ExtensionContext, max: number): string[] {
  const branch: unknown[] = ctx.sessionManager.getBranch();
  const userMessages: string[] = [];

  for (let i = branch.length - 1; i >= 0 && userMessages.length < max; i--) {
    const entry = branch[i];
    if (!isSessionEntry(entry)) {
      continue;
    }
    if (entry.type !== "message" || entry.message.role !== "user") {
      continue;
    }
    const text = extractUserText(entry.message.content);
    if (text.length > 0) {
      userMessages.unshift(text);
    }
  }

  return userMessages;
}

// ---------------------------------------------------------------------------
// Prompt & response
// ---------------------------------------------------------------------------

function buildPrompt(messages: string[]): string {
  return messages.map((msg, idx) => `${idx + 1}. ${msg}`).join("\n");
}

function extractTitle(blocks: unknown[]): string {
  for (let i = blocks.length - 1; i >= 0; i--) {
    const block = blocks[i] as Record<string, unknown>;
    if (block.type === "text" && typeof block.text === "string") {
      const text = (block.text as string).trim();
      if (text.length > 0) {
        return text;
      }
    }
  }
  return "";
}

// ---------------------------------------------------------------------------
// Command handler
// ---------------------------------------------------------------------------

async function generateSessionName(
  pi: ExtensionAPI,
  ctx: ExtensionCommandContext,
): Promise<void> {
  const userMessages = getLastUserMessages(ctx, 10);
  if (userMessages.length === 0) {
    ctx.ui.notify("No user messages found to name this session", "warning");
    return;
  }

  const model = ctx.model;
  if (model === null || model === undefined) {
    ctx.ui.notify("No current model selected", "warning");
    return;
  }

  const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
  if (!auth.ok) {
    ctx.ui.notify(auth.error, "warning");
    return;
  }

  ctx.ui.notify("Generating session name...", "info");

  try {
    const response = await completeSimple(
      model,
      {
        systemPrompt:
          "Create a concise session title (under 80 characters) based on " +
          "the recent user messages. Reply with the title and nothing else.",
        messages: [
          {
            role: "user" as const,
            content: buildPrompt(userMessages),
            timestamp: Date.now(),
          },
        ],
      },
      {
        apiKey: auth.apiKey,
        headers: auth.headers,
        maxTokens: 4096,
        signal: AbortSignal.timeout(60_000),
      },
    );

    const name = extractTitle(response.content as unknown[]);

    if (name.length === 0) {
      ctx.ui.notify("Model returned an empty session name", "warning");
      return;
    }

    pi.setSessionName(name);
    ctx.ui.notify(`Session named: ${name}`, "info");
  } catch (error: unknown) {
    console.warn(
      "session-auto-name: failed to generate session name",
      error instanceof Error ? error.message : String(error),
    );
    ctx.ui.notify("Failed to generate session name", "error");
  }
}

// ---------------------------------------------------------------------------
// Registration
// ---------------------------------------------------------------------------

export default function sessionAutoName(pi: ExtensionAPI): void {
  pi.registerCommand("rename", {
    description: "Auto-generate a session name from the last 10 user messages",
    handler: async (_args: string[], ctx: ExtensionCommandContext) => {
      await generateSessionName(pi, ctx);
    },
  });
}
