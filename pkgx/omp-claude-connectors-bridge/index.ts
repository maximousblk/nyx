/**
 * Claude account connectors via the existing Claude login. Internal API; errors are not retried or recovered.
 */
import assert from "node:assert/strict";
import { once } from "node:events";
import { randomUUID } from "node:crypto";
import { readFile } from "node:fs/promises";
import { request } from "node:https";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const servers_url = "https://api.anthropic.com/v1/mcp_servers?limit=1000";
const proxy_url = "https://mcp-proxy.anthropic.com/v1/mcp/";

const decoders: Record<string, (text: string) => any[]> = {
  "application/json": (text) => [JSON.parse(text)],
  "text/event-stream": (text) => [...text.matchAll(/^data: ?(.*)$/gm)].map((line) => JSON.parse(line[1])),
};

function bridgeError(code: string, message: string) {
  return new Error(`${code}: ${message}\nSee the omp-claude-connectors-bridge skill for guidance.`);
}

async function send(
  method: string,
  url: string,
  body: string,
  headers: Record<string, string>,
  signal = new AbortController().signal,
) {
  const dir = process.env.CLAUDE_CONFIG_DIR || join(homedir(), ".claude");
  const { accessToken, expiresAt } = JSON.parse(await readFile(join(dir, ".credentials.json"), "utf8")).claudeAiOauth;
  if (!Number.isFinite(expiresAt)) {
    throw bridgeError("CLAUDE_OAUTH_EXPIRY_INVALID", "Claude OAuth credentials have no valid expiry.");
  }
  if (expiresAt <= Date.now()) {
    throw bridgeError("CLAUDE_OAUTH_EXPIRED", "Claude OAuth token expired before the request was sent.");
  }
  const req = request(url, {
    method,
    family: 4,
    signal: AbortSignal.any([AbortSignal.timeout(120_000), signal]),
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "anthropic-version": "2023-06-01",
      "anthropic-beta": "mcp-servers-2025-12-04",
      "Content-Type": "application/json",
      Accept: "application/json, text/event-stream",
      ...headers,
    },
  });
  req.end(body);
  const [res] = await once(req, "response");
  let text = "";
  for await (const chunk of res.setEncoding("utf8")) text += chunk;
  assert(res.statusCode < 300, `Claude MCP HTTP ${res.statusCode}`);
  return { text, response: res.headers };
}

async function rpc(id: string, headers: Record<string, string>, method: string, params: object, signal?: AbortSignal) {
  const requestId = randomUUID();
  const body = JSON.stringify({ jsonrpc: "2.0", id: requestId, method, params });
  const { text, response } = await send("POST", proxy_url + id, body, headers, signal);
  const messages = decoders[response["content-type"]!.split(";")[0]](text);
  const reply = messages.find((message) => message.id === requestId);
  assert(!reply.error, JSON.stringify(reply.error));
  return { result: reply.result, response };
}

async function servers(signal?: AbortSignal) {
  const data: any[] = [];
  let query = "";
  do {
    const list = JSON.parse((await send("GET", servers_url + query, "", {}, signal)).text);
    data.push(...list.data);
    query = list.next_page && `&page=${list.next_page}`;
  } while (query);
  return data;
}

async function connect(selector: string, signal?: AbortSignal, clientSessionId = randomUUID()) {
  const matches = (await servers(signal)).filter((s: any) => [s.id, s.display_name, s.url].includes(selector));
  assert.equal(matches.length, 1, `Expected exactly one connector matching ${selector}`);
  const [{ id }] = matches;
  const headers: Record<string, string> = { "X-Mcp-Client-Session-Id": clientSessionId };
  const init = {
    protocolVersion: "2025-03-26",
    capabilities: {},
    clientInfo: { name: "omp-claude-connectors-bridge", version: "1.0" },
  };
  const { result, response } = await rpc(id, headers, "initialize", init, signal);
  headers["MCP-Protocol-Version"] = result.protocolVersion;
  if (typeof response["mcp-session-id"] === "string") {
    headers["Mcp-Session-Id"] = response["mcp-session-id"];
  }
  const initialized = JSON.stringify({ jsonrpc: "2.0", method: "notifications/initialized", params: {} });
  await send("POST", proxy_url + id, initialized, headers, signal);
  return { id: id as string, headers };
}

async function tools(selector: string, signal?: AbortSignal, clientSessionId?: string) {
  const { id, headers } = await connect(selector, signal, clientSessionId);
  const tools: any[] = [];
  let params: { cursor?: string } = {};
  do {
    const { result } = await rpc(id, headers, "tools/list", params, signal);
    tools.push(...result.tools);
    params = { cursor: result.nextCursor };
  } while (params.cursor);
  return tools;
}

async function call(selector: string, tool: string, args: object, signal?: AbortSignal, clientSessionId?: string) {
  const { id, headers } = await connect(selector, signal, clientSessionId);
  const { result } = await rpc(id, headers, "tools/call", { name: tool, arguments: args }, signal);
  assert(!result.isError, JSON.stringify(result));
  return result;
}

export default async function (pi: ExtensionAPI) {
  const { Type } = await import("@earendil-works/pi-ai");
  const server = Type.String({ description: "Exact connector display name, ID, or upstream URL" });
  const output = (value: unknown) => ({
    content: [{ type: "text" as const, text: JSON.stringify(value, null, 2) }],
    details: value,
  });
  pi.registerTool({
    name: "claude_connectors",
    label: "Claude connectors",
    description: "List Claude account MCP connectors. Discovery does not authorize actions or guarantee connectivity.",
    parameters: Type.Object({}),
    execute: async (_id, _args, signal) => output(await servers(signal)),
  });
  pi.registerTool({
    name: "claude_connectors_tools",
    label: "Claude connector tools",
    description: "Discover exact tool names, descriptions, and input schemas before calling a Claude connector.",
    parameters: Type.Object({ server }),
    execute: async (_id, args, signal, _onUpdate, ctx) =>
      output(await tools(args.server, signal, ctx.sessionManager.getSessionId())),
  });
  pi.registerTool({
    name: "claude_connectors_call",
    label: "Call Claude connector",
    description:
      "Call a discovered Claude connector tool with arguments matching its schema. Writes require user authorization. Never replay a failed call automatically: it may have executed. Resolve approval/auth errors in the official Claude client.",
    parameters: Type.Object({ server, tool: Type.String(), arguments: Type.Record(Type.String(), Type.Unknown()) }),
    execute: async (_id, args, signal, _onUpdate, ctx) =>
      output(await call(args.server, args.tool, args.arguments, signal, ctx.sessionManager.getSessionId())),
  });
}

if (import.meta.main) {
  const [command, server, tool] = process.argv.slice(2);
  const commands: Record<string, () => Promise<unknown>> = {
    servers: () => servers(),
    tools: () => tools(server),
    call: async () => call(server, tool, JSON.parse(await readFile(0, "utf8"))),
  };
  console.log(JSON.stringify(await commands[command]()));
}
