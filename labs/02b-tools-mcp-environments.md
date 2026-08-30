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

## Scenario

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

VS Code requires the top-level `servers` key. This configuration:

- Uses browser-based OAuth, so no token is stored.
- Loads only the named GitHub toolsets.
- Withholds all write tools on the server.

Approval is not configured here. Use a hook or human approval gate for operations that require approval.

### Check your work

Ask an agent to merge a pull request through MCP. It should report that no merge tool is available.

---

## Exercise 2 — Define execution boundaries

**Update this file:** `agent-task-brief.md`

Its **Execution boundaries** section has six scope subsections. Add a seventh, **Infrastructure and secrets scope**:

```markdown
### Infrastructure and secrets scope

- Reach the cart API and MCP tools only through the endpoints named in this brief.
- Do not change `allowedIpAddressRange`, ingress settings, or probe configuration in `infra/resources.bicep` as part of a task.
- Do not replace `cartApiImage` with a moving tag; the deployed build must stay identifiable.
- Do not add environment variables or secrets to the container definition.
- Treat `infra/` as sensitive, the same as `.github/` and `tools/`.
- Do not modify an execution boundary to make the current task succeed.
```

Write each boundary as a rule the agent can follow, not as a suggestion.

### The boundary an agent will try to move

Boundary rule: An agent must not weaken or modify an execution boundary to make its task succeed.

---

## Exercise 3 — Run the cloud agent

**Review this file:** `.github/workflows/copilot-setup-steps.yml`

- Confirm the filename and job name are copilot-setup-steps.
- Push it to the default branch.
- Assign a task to the Copilot coding agent.
- Confirm Python setup runs before the agent starts.

### Assign work from VS Code

Choose either method:

1. Open Copilot Chat and enter:

   ```text
   Add a docstring to calculate_total in app/cart.py explaining the rounding rule.
   ```

2. Delegate the chat to **Copilot coding agent**.

You can also open a GitHub issue in VS Code and assign it to Copilot.

### Assign work with GitHub CLI

```bash
gh agent-task create "Add a docstring to calculate_total in app/cart.py explaining the rounding rule" --follow
```

To use one of the custom agents from Lab 02a:

```bash
gh agent-task create "Review the open pull request for missing test coverage" \
  --custom-agent reviewer --follow
gh agent-task list
```

`--follow` streams the session log.

---

## Exercise 4 — Agentic workflow

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

The agent remains read-only. `safe-outputs` lets the compiled workflow create only the declared output: an issue, not a pull request.

**The declaration enforces the boundary; the prompt does not.**

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

- Custom agent YAML uses `mcp-servers`; **VS Code's `.vscode/mcp.json` uses plain `servers`**. The wrong key fails silently — the server simply never loads.
- A local process has `command` and `args`. A remote HTTP or SSE server has a `url`.
- A URL passed *inside* a local command's arguments does not make the transport remote.
- Read access to issue context does not imply permission to merge pull requests. Allow-lists are per operation, not per server.

---

## Summary

A read-only MCP configuration, a seventh execution boundary, a cloud-agent environment you ran real work in, and an agentic workflow.

**Next:** [Lab 03 — Manage Memory, State, and Execution](03-memory-state-execution.md)
