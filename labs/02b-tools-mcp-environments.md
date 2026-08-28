# Lab 02b — Tools, MCP, and Environments (Domain 2)

## Introduction

In this lab, you connect agents to external tools, define execution boundaries, configure a cloud-agent environment, and author an agentic workflow.

**Estimated time:** 30 minutes

**Microsoft Learn alignment:** [Tooling, MCP, and Agent Execution Environments](https://learn.microsoft.com/en-us/training/modules/agent-tooling-mcp-execution-environments/)

## Learning objectives

After completing this lab, you'll be able to:

- Configure read-only MCP servers for a repository.
- Distinguish documented restrictions from enforced restrictions.
- Define boundaries that an agent cannot widen.
- Configure and run a GitHub Copilot cloud agent.
- Author and validate an agentic workflow with safe outputs.
- Identify branch, pull request, and environment protections that limit execution.

## Prerequisites

- Complete [Lab 02a — Build Custom Agents](02a-custom-agents.md).
- Retain the task brief from [Lab 01 — Prepare Agent Architecture](01-agent-architecture-sdlc.md).

## Lab scenario

The custom agents now need external context and a repeatable execution environment. You must connect those capabilities without granting unnecessary write access or allowing the agent to redefine its own boundaries.

**Lab outputs:**

| Step | File | Purpose |
| --- | --- | --- |
| 1 | `.vscode/mcp.json` | External tool servers, read-only |
| 2 | `agent-task-brief.md` | Execution boundaries an agent cannot widen |
| 3 | `.github/workflows/copilot-setup-steps.yml` | Cloud-agent environment, then run the agent |
| 4 | `.github/workflows/test-coverage-review.md` | An agentic workflow |

---

## Exercise 1 — Configure MCP servers

**Create this file:** `.vscode/mcp.json`

```json
{
  "servers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "X-MCP-Toolsets": "repos,issues,pull_requests,actions",
        "X-MCP-Readonly": "true"
      }
    }
  }
}
```

VS Code reads `.vscode/mcp.json`. Copilot CLI and the cloud agent read `.mcp.json` at the repository root — same servers, but the top-level key is `mcpServers` instead of `servers`. Create both if you want the config to apply everywhere; the wrong key fails silently, which is why the Verify below checks the key name rather than just the JSON.

### No token

The remote GitHub MCP server authenticates with OAuth. You log in through the browser on first use; there is nothing to create, paste, rotate, or leak.

This is the strongest version of the secrets rule. Lab 01 said never commit a credential. Here you go one better: **the safest credential is the one that does not exist.** Before writing a config that consumes a token, check whether the service offers OAuth instead — for the exam, and for real work.

If you must run the server locally in Docker a token is required — reference it as `${input:github_token}`, never inline. A shell-style `$GITHUB_TOKEN` is not interpolated in this file and would be passed through as a literal string.

### Where the restriction is actually enforced

Two headers do the work, and they are not equivalent:

| Header | Effect | Enforced where |
| --- | --- | --- |
| `X-MCP-Toolsets` | Only the named toolsets load | **Server side** |
| `X-MCP-Readonly` | Every write tool is withheld, in every loaded toolset | **Server side** |

That distinction is the point of this step. A client-side allow-list is a list the client agrees to honour. These headers mean the server never offers the write tools at all — an agent cannot call `merge_pull_request` because it was never given one to call.

Appending `/readonly` to the URL does the same thing: `https://api.githubcopilot.com/mcp/x/issues/readonly`.

### The allow-list decision

Compare your config against the fuller design in [tools/mcp.allow-list.example.json](../tools/mcp.allow-list.example.json), which sorts operations into allowed, requires-approval, and denied. Then answer: **where is each category enforced?**

| Category | Enforced by | Enforced where |
| --- | --- | --- |
| Allowed | `X-MCP-Toolsets` | Server, at connection time |
| Denied | `X-MCP-Readonly`, or omission from the toolset list | Server, at connection time |
| Requires approval | ? | ? |

Fill in the last row. There is no approval concept anywhere in `.mcp.json` — it exists in your design document and in no configuration you have written. Name the control that actually implements it. Lab 06 builds it; this is the gap it fills.

> [!NOTE]
> A wrong top-level key fails silently. The server simply never loads, and no error is shown.

```bash
python3 - <<'EOF'
import json, pathlib
for path, key in [(".vscode/mcp.json", "servers"), (".mcp.json", "mcpServers")]:
    p = pathlib.Path(path)
    if not p.exists():
        print(f"SKIP: {path} not created"); continue
    d = json.load(p.open())
    assert key in d, f"{path} must use the top-level key '{key}'"
    h = d[key]["github"].get("headers", {})
    assert h.get("X-MCP-Readonly") == "true", f"{path}: write tools are not withheld"
    print(f"PASS: {path} valid, read-only, correctly keyed")
EOF
```

Ask an agent to merge a pull request through MCP. It should report that no such tool is available — not that it declined. Those are different failures, and only the first is a boundary.

---

## Exercise 2 — Define execution boundaries

**Update this file:** `agent-task-brief.md`

Its **Execution boundaries** section needs all seven scopes. Six are there. Add the seventh:

```markdown
- Reach the cart API and MCP tools only through the endpoints named in this brief.
- Do not change `allowedIpAddressRange`, ingress settings, or probe configuration in `infra/resources.bicep` as part of a task.
- Do not replace `cartApiImage` with a moving tag; the deployed build must stay identifiable.
- Do not add environment variables or secrets to the container definition.
- Treat `infra/` as sensitive, the same as `.github/` and `tools/`.
```

Write each boundary as a rule the agent can follow, not as a suggestion.

### The boundary an agent will try to move

A boundary is only real if the agent cannot widen it to make its own error go away. If a task fails with `403` because the agent is outside an allowed address range, the fix is to investigate — not to add itself to the range. An agent that edits `allowedIpAddressRange` to unblock itself has not solved a problem; it has removed a control and reported success.

State that explicitly in the brief. "Do not modify a boundary in order to satisfy the current task" is the rule that separates a boundary from a suggestion.

---

## Exercise 3 — Run the cloud agent

**Review this file:** `.github/workflows/copilot-setup-steps.yml`

Copilot's coding agent runs on GitHub's infrastructure, not yours. It reads this file to prepare its environment before starting. Three rules make it work:

- The **filename must be exactly** `copilot-setup-steps.yml`.
- The **job must be named** `copilot-setup-steps`.
- The file **must be on your default branch**. It does not trigger from a feature branch.

Get any of them wrong and the file is silently ignored — no error, no warning.

### Only six keys are honoured

Inside the `copilot-setup-steps` job, Copilot reads `steps`, `permissions`, `runs-on`, `services`, `snapshot`, and `timeout-minutes` (capped at 59). **Every other job setting is ignored**, and any `fetch-depth` you set on `actions/checkout` is overridden. Writing `needs:`, `if:`, or `strategy:` here does nothing — it fails silently, which is the theme of this step.

### A failing setup step does not stop the agent

This is the part worth memorising, and it is the opposite of what most people assume. If a setup step exits non-zero, **Copilot skips the remaining setup steps and starts working anyway**, in a half-prepared environment.

So the danger is not that a broken setup blocks the agent. It is that the agent proceeds without the dependency you thought you installed, then fails later for a reason that has nothing to do with the failure's real cause. That is an *environment issue* wearing the costume of a reasoning error — exactly the misclassification Lab 04 asks you to avoid.

It is also why this file does not run the test suite. Setup prepares; the agent validates.

### Assign work to the cloud agent

```bash
gh agent-task create "Add a docstring to calculate_total in app/cart.py explaining the rounding rule" --follow
```

To run it as one of the agents you built in Lab 02a:

```bash
gh agent-task create "Review the open pull request for missing test coverage" \
  --custom-agent reviewer --follow
gh agent-task list
```

`--follow` streams the session log. Watch for the setup steps running *before* the agent's first tool call — that ordering is the whole point of the file.

**Behavioural test:** add a step that runs `exit 1` in the middle of the setup job, push it to your default branch, and assign a task. The agent still runs. Confirm in the session log that setup stopped at your failing step and the agent proceeded regardless — then remove it.

---

## Exercise 4 — Author an agentic workflow

**Create this file:** `.github/workflows/test-coverage-review.md`

A third file type sits between the two you have already built. Custom agents (`.github/agents/*.agent.md`) define *who* an agent is. Actions workflows (`.yml`) define *when* automation runs. **Agentic workflows** are Markdown files in `.github/workflows/` that define an AI task declaratively — trigger, permissions, tools, and allowed outputs in frontmatter, with the instructions as the body.

````markdown
---
on:
  schedule: weekly
  workflow_dispatch:

permissions:
  contents: read
  issues: read
  pull-requests: read

engine: copilot

tools:
  github:
    allowed:
      - get_file_contents
      - list_issues

safe-outputs:
  create-issue:
    title-prefix: "[coverage] "
    labels: [test-coverage, agent-generated]
    close-older-issues: true
---

# Weekly test coverage review

Review `app/` for behaviour no test exercises, check open issues first, and open
one issue listing each gap with the function, why it matters, and the assertion
that would cover it. Do not modify any file.
````

### `safe-outputs` is the control that matters

Note what the `permissions` block grants: `read`, `read`, `read`. The agent cannot write anything. Yet the workflow creates an issue.

That is the point of `safe-outputs`. Write actions do not come from the token the agent holds — they are declared in frontmatter and performed by the compiled workflow after the agent finishes. The agent proposes; the harness writes, and only in the shapes you declared. An agent that decides to open a pull request instead cannot, because `create-pull-request` is not in that block.

This is the same principle as the tool lists in Lab 02a, applied to outputs rather than inputs: **the declaration is the enforcement, not the instruction in the body.**

### Check your work

```bash
gh extension install github/gh-aw   # once
gh aw init                          # once per repository
gh aw validate                      # checks the frontmatter without writing anything
gh aw compile                       # generates the .lock.yml Actions actually runs
```

`gh aw compile` turns each `.md` into a hardened `.lock.yml` beside it. **Commit both** — Actions runs the lock file, not your Markdown. Editing the `.lock.yml` by hand is pointless; the next compile overwrites it.

### Or start from the catalogue

You do not have to write one from scratch. `gh aw` installs workflows from other repositories:

```bash
gh aw add-wizard githubnext/agentics/daily-repo-status
gh aw status
```

Apply the same scrutiny you gave the MCP allow-list in Exercise 1: **read the `tools:` and `safe-outputs:` blocks before compiling.** An installed workflow runs with whatever permissions and write actions its author declared, in your repository. `gh aw validate` tells you it is well-formed — it does not tell you it is safe for you.

```bash
gh aw validate

grep -q "safe-outputs" .github/workflows/test-coverage-review.md \
  && echo "PASS: write actions are declared, not granted"

grep -qE "^\s+contents: write" .github/workflows/test-coverage-review.md \
  && echo "FAIL: the agent should not hold write permission" \
  || echo "PASS: read-only permissions"
```

`gh aw validate` compiles the frontmatter and reports errors without writing a lock file — run it before every commit.

### Check the result

Run the workflow with `gh aw run test-coverage-review`, then check the issue it opened. The issue is authored by the workflow, not by you — which is the attribution question Lab 01 Exercise 3 asked you to trace.

---

## Knowledge check

You completed the lab if you can explain:

- Which part of your MCP allow-list is actually enforced, and which part is only documented
- Why a server-side read-only header is a stronger control than a client-side tool list
- Why a boundary an agent may widen is not a boundary
- What happens when a `copilot-setup-steps` step fails, and why that is worse than it stopping
- How an agentic workflow can create an issue while holding only read permissions

---

## Exam preparation

- GH-600 questions in this domain combine tool choice with execution scope. The best answer separates tool selection, approval, and execution boundaries.
- Watch for answers that grant broad permissions, bypass pull requests, expose secrets, or let agents modify governance files without review.

### MCP configuration traps

- Custom agent YAML uses `mcp-servers`; repository `.mcp.json` uses `mcpServers`; **VS Code's `.vscode/mcp.json` uses plain `servers`**. The wrong one fails silently — the server simply never loads.
- A local process has `command` and `args`. A remote HTTP or SSE server has a `url`.
- A URL passed *inside* a local command's arguments does not make the transport remote.
- Read access to issue context does not imply permission to merge pull requests. Allow-lists are per operation, not per server.

### Cloud-agent setup

| Rule | Consequence if broken |
| --- | --- |
| Filename exactly `copilot-setup-steps.yml` | Silently ignored |
| Job named `copilot-setup-steps` | Silently ignored |
| Present on the **default branch** | Never triggers |
| Only `steps`, `permissions`, `runs-on`, `services`, `snapshot`, `timeout-minutes` | Other keys silently ignored |

**A failing setup step does not block the agent.** Copilot skips the rest of setup and works anyway, in a partially prepared environment. Expect exam answers claiming the run halts — they are wrong.

### Which file does what

| File | Defines | Scope |
| --- | --- | --- |
| `.github/copilot-instructions.md` | Conventions every agent reads | Entire repository |
| `.github/instructions/*.instructions.md` | Path-specific guidance | An `applyTo` glob |
| `AGENTS.md` | Agent-oriented docs | Read by multiple agent tools |
| `.github/agents/*.agent.md` | Who an agent is — persona and tool list | Runs when you select it |
| `.github/workflows/*.yml` | Conventional CI automation | Runs on its trigger |
| `.github/workflows/*.md` | An AI task — trigger, tools, safe outputs | Runs after `gh aw compile` |
| `.mcp.json` / `.vscode/mcp.json` | MCP servers | Repository or editor |

- Agentic workflows compile to `.lock.yml`; Actions runs the lock file. Commit both.
- `gh aw validate` checks frontmatter without writing; `gh aw compile` writes the lock file.
- `safe-outputs` declares permitted write actions, so the agent's own permissions can stay read-only.
- `engine` selects the model provider — Copilot, Claude, Codex, Gemini, or Pi.

---

## Summary

A read-only MCP configuration, a seventh execution boundary, a cloud-agent environment you ran real work in, and an agentic workflow.

**Next:** [Lab 03 — Manage Memory, State, and Execution](03-memory-state-execution.md)
