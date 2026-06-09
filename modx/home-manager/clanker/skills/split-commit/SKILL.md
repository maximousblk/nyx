---
description: Split current working tree changes into isolated, hermetic git commits
argument-hint: "[extra constraints]"
---
Split the current working tree changes into isolated, hermetic git commits.

If the user supplied extra instructions, they are mandatory constraints.

User: $@

# Objective

Turn the current working tree into the smallest reasonable sequence of clean commits.

Target outcome:

- each commit is independently understandable
- each commit is scoped to one real subsystem area
- commit messages match this repo's house style exactly
- unrelated changes are separated
- related changes inside the same scope are grouped when splitting further would make the history noisier instead of clearer

You must optimize for **clear reviewable history**, not for the fewest commits and not for maximal fragmentation.

---

# Step 1: Inspect the full state

Run all of these before proposing anything:

1. `git status --short`
2. `git diff --cached --stat`
3. `git diff --stat`
4. For every changed file:
   - `git diff --cached -- <file>` for staged changes
   - `git diff -- <file>` for unstaged changes
5. Read the recent commit history with full bodies and derive the exact style used in this repo.

Use the last 20 relevant commits, with full bodies, and skip flake update auto-commits while studying style.

Use something equivalent to:

```bash
git log --format="%H%n%s%n%b%n---END---" -40
```

While studying style, ignore commits whose purpose is just flake update automation, such as:

- `nix: update flake`
- obvious `flake.lock` update-only commits
- other purely mechanical flake input refresh commits

Do not guess the style from memory. Infer it from the repo before planning.

---

# Step 2: Derive and obey this repo's commit style

Match the observed house style exactly.

## 2.1 Title line format

Use:

```text
type(scope): subject
```

Common types in this repo include:

- `feat`
- `fix`
- `refactor`
- `docs`
- `chore`

Choose the narrowest accurate type:

- `feat` for net-new behavior or capabilities
- `fix` for bug fixes, broken config fixes, compatibility fixes, or wrong behavior
- `refactor` for structural cleanup or reorganization without intended behavior change
- `docs` for documentation-only changes
- `chore` for maintenance that does not fit better elsewhere

## 2.2 Scope rule

Scopes in this repo are usually **path-like and specific**.

Prefer scopes shaped like:

- `victus/home`
- `victus/niri`
- `victus/nixos`
- `victus/browser`
- `victus/kernel`
- `pyre/dns`
- `pyre/torproxy`
- `pyre/containers`
- `pyre/servarr`
- `cairn/network`
- `modx/clanker`
- `modx/secrets`
- `modx/tailscale-services`
- `umbra/home`
- `umbra/git`
- `umbra/opencode`
- `remora/nixos`
- `pkgx/wallpapers`
- `flake`
- `topology`

### Scope selection rule

Pick the scope by finding the **narrowest real subsystem path** that best describes the change.

Use this rule in order:

1. If the change is host-specific, prefer `host/subsystem`.
2. If the change is in a shared module area, prefer `module/subsystem`.
3. If the change is truly top-level or repo-wide, use a top-level scope like `flake`, `topology`, or another clearly established top-level area.
4. If proposed grouping would force multiple unrelated scopes into one commit, split the commit instead.

### Scope naming requirements

- Scope must be concrete.
- Scope must map to a real area of the repo.
- Scope should usually resemble the path or ownership boundary of the changed files.
- Prefer slash-separated scopes over vague umbrella names.
- Do not invent filler scopes like `misc`, `general`, `cleanup`, `stuff`, or `updates`.
- Do not widen scope just to avoid making another commit.
- Ban bare host scopes like `victus`, `pyre`, `umbra`, `cairn`, or `remora` unless the user explicitly approves that broader grouping.
- Ban generic bare scopes like `home`, `system`, `browser`, `shell`, `nixos`, `kernel`, `audio`, `ui`, `docs`, or `pkg` when a narrower real scope exists.
- Prefer `host/subsystem` or `module/subsystem` over any bare umbrella scope.
- If the natural scope is too broad, split the commit instead of using a broad scope.

## 2.3 Subject line rule

The subject line must be:

- short
- direct
- lowercase
- imperative in tone
- without a trailing period

Good subject patterns in this repo:

- `drop hardcoded br0 MTU`
- `swap MCP servers and update model names`
- `use displayManager autoLogin instead of custom PAM service in ly`
- `note set-config HTTPS bug and revisit path`

Do not write vague subjects like:

- `misc fixes`
- `cleanup`
- `improvements`
- `more changes`
- `update config`
- `tweak settings`
- `fix stuff`

## 2.4 Body format rule

When a body is warranted, it must follow this format:

- no prose paragraph before the bullets
- one bullet per concrete change
- every bullet starts with `- `
- each bullet describes an actual staged change
- bullets should be specific, not generic
- wording should stay concise and literal

Preferred bullet verbs in this repo include:

- `Add`
- `Remove`
- `Drop`
- `Replace`
- `Switch`
- `Move`
- `Disable`
- `Enable`
- `Consolidate`
- `Extract`
- `Regenerate`
- `Patch`
- `Simplify`

A body is especially appropriate when:

- the commit touches several files in one scope
- the subject alone does not fully explain the staged changes
- there are multiple discrete modifications worth enumerating

If the commit is truly tiny and self-evident, a body may be omitted.

## 2.5 Footnote rule for references

This repo uses numbered markdown footnotes for external references.

If any bullet refers to an upstream issue, PR, release note, doc, or other URL, use this exact style:

1. Put the marker at the end of the relevant bullet:
   - `[1]`
   - `[1][2]`
2. Finish the bullet list.
3. Insert one blank line.
4. Add footnotes in numeric order:

```text
[1]: https://example.com/one
[2]: https://example.com/two
```

Footnote requirements:

- do not inline raw URLs in bullets
- do not write named references like `fixed in repo#123`
- the footnote marker is the only inline reference form
- only include footnotes that are actually referenced by bullets
- numbering must be local to that commit message and internally consistent

Example:

```text
fix(victus/nixos): use displayManager autoLogin instead of custom PAM service in ly
- Replace manual pam.services.ly-autologin with services.displayManager.autoLogin
- Set defaultSession = "niri" via services.displayManager
- ly v1.3.0 added native auto-login support [1][2]

[1]: https://github.com/NixOS/nixpkgs/pull/473013
[2]: https://github.com/NixOS/nixpkgs/pull/420889
```

---

# Step 3: Plan the commit split

Now analyze the diffs and group changes into commits.

## Core splitting principle

Split as much as possible **without making the history worse**.

That means:

- split unrelated changes aggressively
- split different scopes aggressively
- split behavior changes from refactors when they are meaningfully separable
- split docs-only changes unless they are tightly coupled to a specific code/config change
- keep generated artifacts with the commit that requires them

But also:

- keep changes together when they belong to the same scope and the same purpose
- keep adjacent hunks together when separating them would create artificial or confusing history
- prefer one coherent commit over multiple tiny commits that all describe the same subsystem change

## Balancing rule

Use this balancing test for every proposed split:

**Split the commit** if doing so makes the history easier to review, easier to revert, or more semantically accurate.

**Keep the changes together** if they:

- affect the same scope,
- serve one clear purpose,
- and would require awkward duplicated commit messages or arbitrary hunk separation if split.

## Planning requirements

Each planned commit must satisfy all of these:

- exactly one clear purpose
- one primary narrow scope
- a plausible standalone commit message in final repo style
- no unrelated spillover hunks
- no mixed concerns just because the edits were nearby
- no banned broad or generic scope unless the user explicitly asked for it

If one file contains multiple concerns, plan to split it by hunk.

If several files all belong to one scope and one purpose, prefer one coherent commit over a pile of micro-commits.

---

# Step 4: Present the plan and wait

Before modifying the index or creating commits, present the plan as a markdown table with these columns:

| # | Scope | Files | Commit message | Body bullets |
|---|---|---|---|---|

Requirements for the plan:

- `Scope` must reflect the final chosen scope.
- `Files` must list all files involved in that commit.
- `Commit message` must already be written in final `type(scope): subject` form.
- `Body bullets` must be near-final and specific.
- If footnotes will be used, include the markers in the bullets and list the footnotes below that commit's bullets.
- Explicitly mention when a file must be split by hunk.
- If there is any judgment call about whether to group or split, say so briefly.
- If a broader scope was considered and rejected, prefer the narrower one and do not surface the broad one unless the user asks.

Then stop.

Do not stage anything.
Do not commit anything.
Wait for user approval or corrections.

---

# Step 5: Execute only after approval

After the user approves the plan:

1. Unstage everything first:

```bash
git reset HEAD -- .
```

2. Create commits in the approved order.

3. Stage only the files or hunks for the current commit.

Allowed staging approach:

- use `git add <file1> <file2> ...` for whole-file commits
- use patch/hunk staging when one file belongs to multiple commits

4. If a file must be split by hunk, isolate only the approved hunks.

5. Before each commit, verify the staged diff matches the plan.

Recommended checks:

```bash
git diff --cached --stat
git diff --cached -- <file>
```

6. Commit using exact multiline heredoc format:

```bash
git commit -m "$(cat <<'EOF'
<title line>

<body bullets>
EOF
)"
```

7. After all commits, verify the result:

```bash
git log --oneline -N
git log --format="%h %s%n%b---" -N
```

Where `N` is the number of commits created.

---

# Pre-commit quality checklist

Before creating each commit, confirm all of the following are true:

- the staged diff matches one coherent purpose
- the scope is the narrowest accurate scope
- the scope is not a banned broad/generic scope unless the user explicitly approved it
- the title line matches this repo's style
- the subject is concrete and not vague
- the body bullets describe only staged changes
- footnotes are formatted correctly if references are present
- no unrelated formatting churn was accidentally included
- no second scope slipped into the commit

---

# Hard restrictions

- NEVER add `Co-Authored-By` trailers.
- NEVER add attribution or watermark text.
- NEVER use `git add -A`.
- NEVER use `git add .`.
- NEVER amend existing commits unless the user explicitly asks.
- NEVER push unless the user explicitly asks.
- NEVER commit likely secrets such as `.env`, private keys, credentials, or tokens.
- If the working tree is clean, report that and stop.
