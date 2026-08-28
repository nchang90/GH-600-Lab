# Lab 02 — Implement Tool Use and Environment Interaction (Domain 2)

**Goal:** build a set of specialized agents with deliberately different capabilities, connect them to external tools, and bound the environment they run in.

**You will create:**

| Step | File | Purpose |
| --- | --- | --- |
| 1 | `.github/agents/reviewer.agent.md` | Low-autonomy reviewer that cannot edit |
| 2 | `.github/agents/test-runner.agent.md` | Medium-autonomy test executor |
| 3 | `.github/agents/security-scanner.agent.md` | Analyst that can run checks but not fix |
| 4 | `.github/agents/orchestrator.agent.md` | Delegating coordinator |
| 5 | `.mcp.json` | External tool servers |
| 6 | `agent-task-brief.md` | Execution boundaries an agent cannot widen |
| 7 | `.github/workflows/copilot-setup-steps.yml` | Cloud-agent environment, then run the agent |
| 8 | `.github/workflows/test-coverage-review.md` | An agentic workflow |

**Prerequisite:** [Lab 01](01-agent-architecture-sdlc.md) complete.

**Time:** About 50 minutes

## Agent file

Every file in `.github/agents/` has YAML frontmatter and a markdown body that becomes the agent's system prompt.

````markdown
---
name: example
description: "One sentence describing when to use this agent."
tools:
  - read
  - search
---

You are ... (the body becomes the agent's instructions)
````

**`description` is the field that matters most.** A coordinating agent reads it when deciding whether to delegate, so write it as *when you would use this*, not *what this is*.

### The available tools

| Tool | Grants |
| --- | --- |
| `read` | Reading file contents |
| `search` | Searching across the codebase |
| `edit` | Creating and modifying files |
| `execute` | Running shell commands |
| `agent` | Invoking other agents |
| `web` | Fetching external web content |

---

## Step 1 — The reviewer agent (low autonomy)

**Create this file:** `.github/agents/reviewer.agent.md`

````markdown
---
name: reviewer
description: "Reviews changes to the cart application for defects, security risks, missing tests, and violations of repository conventions."
tools:
  - read
  - search
---

You are a read-only code reviewer for this repository.

## Review checklist

1. Identify correctness and security defects.
2. Check input validation and error handling in `app/`.
3. Confirm monetary calculations round only at the boundary, not on every operation.
4. Identify missing tests for changed behavior in `tests/`.
5. Check whether the change touches `.github/`, `tools/`, or `infra/`.
6. Check for committed secrets or credentials.

## Constraints

- Do not edit files.
- Do not execute commands.
- Report only actionable findings supported by code evidence.
- List the most severe findings first.

````


**Behavioural test:** select `reviewer` in the agent picker and ask it to fix a bug in `app/cart.py`. It should report the bug and decline to change the file. That refusal is the feature.

---

## Step 2 — The test-runner agent (medium autonomy)

**Create this file:** `.github/agents/test-runner.agent.md`

````markdown
---
name: test-runner
description: "Runs the cart application test suite, diagnoses failures, and repairs broken tests when the fault is in test code."
tools:
  - read
  - search
  - edit
  - execute
---

You are the test execution and analysis agent for this repository.

## Responsibilities

1. Run the test suite for the changed code.
2. Diagnose failures using test output and source evidence.
3. Repair broken or missing tests when the fix is clearly in test code.
4. Report results and remaining risks.

## Commands

- Full suite: `python3 -m unittest discover -s tests`
- Single module: `python3 -m unittest tests.test_cart`

Run from the repository root. The tests import `app.cart`, which resolves only from the root.

## Constraints

- Do not weaken or delete assertions to make a test pass.
- Do not change `app/` to satisfy a failing test without first stating the cause.
- Report the exact command and its result.
- Do not edit `.github/`, `tools/`, or `infra/`.

````

**Behavioural test:** break an assertion in `tests/test_cart.py`, then ask `test-runner` to investigate. It should identify the specific failing test and say whether the fault is in the test or in `app/cart.py`.

---

## Step 3 — The security-scanner agent

**Create this file:** `.github/agents/security-scanner.agent.md`

````markdown
---
name: security-scanner
description: "Inspects changes for secrets, permission escalation, and weakened controls; reports findings without remediating them."
tools:
  - read
  - search
  - execute
---

You are the security analysis agent for this repository.

## Responsibilities

1. Check for committed credentials, tokens, or connection strings.
2. Check whether workflow permissions, required checks, or branch protections were weakened.
3. Check whether `infra/resources.bicep` changed in a way that widens exposure — a broader
   `allowedIpAddressRange`, `ingressAllowInsecure` set to true, or a mutable image tag
   replacing an explicit commit reference.
4. Report findings with severity and evidence.

## Constraints

- Do not fix what you find. Report it.
- Do not edit files.
- Quote the specific line that supports each finding.

````

## Step 4 — The orchestrator agent

**Create this file:** `.github/agents/orchestrator.agent.md`

````markdown
---
name: orchestrator
description: "Coordinates the reviewer, test-runner, and security-scanner agents and consolidates their output into one reviewable report."
tools:
  - read
  - search
  - agent
---

You are the coordination agent for this repository.

## Responsibilities

1. Decide which specialized agents a task requires.
2. Delegate to them with a clear, bounded instruction each.
3. Consolidate their findings into one report.
4. Flag contradictions between agents rather than silently picking a winner.

## Delegation rules

- Code quality and convention findings: `reviewer`
- Test execution and diagnosis: `test-runner`
- Secrets, permissions, and infrastructure exposure: `security-scanner`

## Constraints

- Do not edit files. Delegate every change to `test-runner`.
- Do not execute commands directly.
- Do not summarize away a disagreement between two agents; report both positions.

````


## Step 5 — Configure MCP servers

**Create this file:** `.mcp.json`

```json
{
  "mcpServers": {
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

Ask an agent to merge a pull request through MCP. It should report that no such tool is available — not that it declined. Those are different failures, and only the first is a boundary.

---

## Step 6 — Define execution boundaries

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

**Verify:**

```bash
grep -q "### Deployment environment" agent-task-brief.md \
  && echo "PASS: seventh boundary added"

n=$(grep -c "^### " agent-task-brief.md)
[ "$n" -eq 7 ] && echo "PASS: 7 scopes" || echo "FAIL: $n scopes, expected 7"
```

---

## Step 7 — Run the cloud agent

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

To run it as one of the agents you built in Steps 1–4:

```bash
gh agent-task create "Review the open pull request for missing test coverage" \
  --custom-agent reviewer --follow
gh agent-task list
```

`--follow` streams the session log. Watch for the setup steps running *before* the agent's first tool call — that ordering is the whole point of the file.

**Verify:**

```bash
python3 - <<'EOF'
import yaml
d = yaml.safe_load(open(".github/workflows/copilot-setup-steps.yml"))
job = d["jobs"].get("copilot-setup-steps")
assert job, "job must be named copilot-setup-steps"
allowed = {"steps", "permissions", "runs-on", "services", "snapshot", "timeout-minutes"}
ignored = set(job) - allowed
assert not ignored, f"these keys are silently ignored: {sorted(ignored)}"
assert job.get("timeout-minutes", 0) <= 59, "timeout-minutes is capped at 59"
print("PASS: job named correctly, no ignored keys")
EOF

git branch --show-current   # must be your default branch for the file to trigger
```

**Behavioural test:** add a step that runs `exit 1` in the middle of the setup job, push it to your default branch, and assign a task. The agent still runs. Confirm in the session log that setup stopped at your failing step and the agent proceeded regardless — then remove it.

---

## Step 8 — Author an agentic workflow

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

Review the cart application for behaviour that is implemented but not tested.

1. Read `app/cart.py` and `app/api.py`.
2. Read `tests/test_cart.py` and `tests/test_api.py`.
3. Identify each input validation or calculation branch in `app/` that no test exercises.
4. Check open issues first; do not raise one that already exists.

Open a single issue listing each gap as:

- **Function** — the function and the specific branch
- **Why it matters** — what breaks if that branch regresses
- **Suggested test** — the assertion that would cover it

Report only gaps you can point to a specific line for. If coverage is complete,
say so and list nothing.

Do not modify any file. This workflow proposes work; it does not perform it.
````

### `safe-outputs` is the control that matters

Note what the `permissions` block grants: `read`, `read`, `read`. The agent cannot write anything. Yet the workflow creates an issue.

That is the point of `safe-outputs`. Write actions do not come from the token the agent holds — they are declared in frontmatter and performed by the compiled workflow after the agent finishes. The agent proposes; the harness writes, and only in the shapes you declared. An agent that decides to open a pull request instead cannot, because `create-pull-request` is not in that block.

This is the same principle as Step 1's tool list, applied to outputs rather than inputs: **the declaration is the enforcement, not the instruction in the body.**

**Verify:**

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

Apply the same scrutiny you gave the MCP allow-list in Step 5: **read the `tools:` and `safe-outputs:` blocks before compiling.** An installed workflow runs with whatever permissions and write actions its author declared, in your repository. `gh aw validate` tells you it is well-formed — it does not tell you it is safe for you.

```bash
gh aw validate

grep -q "safe-outputs" .github/workflows/test-coverage-review.md \
  && echo "PASS: write actions are declared, not granted"

grep -qE "^\s+contents: write" .github/workflows/test-coverage-review.md \
  && echo "FAIL: the agent should not hold write permission" \
  || echo "PASS: read-only permissions"
```

`gh aw validate` compiles the frontmatter and reports errors without writing a lock file — run it before every commit.

**Behavioural test:** run it with `gh aw run test-coverage-review`, then check the issue it opened. The issue is authored by the workflow, not by you — which is the attribution question Lab 01 Step 3 asked you to trace.

---

## Self-check

You completed the lab if you can explain:

- Why the tool list, not the prompt, is what guarantees the reviewer cannot edit
- Why the orchestrator is deliberately less capable than the test-runner
- Why the security-scanner has `execute` but not `edit`
- Which part of your MCP allow-list is actually enforced, and which part is only documented
- How an agentic workflow can create an issue while holding only read permissions
- Why a server-side read-only header is a stronger control than a client-side tool list
- What happens when a `copilot-setup-steps` step fails, and why that is worse than it stopping
- Why a boundary an agent may widen is not a boundary

---

## Exam notes

- GH-600 questions in this domain combine tool choice with execution scope. The best answer usually separates tool selection, approval, and execution boundaries.
- Watch for answers that grant broad permissions, bypass pull requests, expose secrets, or let agents modify governance files without review.
- **Instructions guide; tool lists enforce.** If a question asks how you *guarantee* a capability is absent, the answer is never "tell the agent not to."
- `description` is the field a delegating agent reads. A vague description is why an orchestrator picks the wrong specialist.
- **The orchestrator is deliberately weaker than the agents it directs.** It holds `agent` but not `edit` or `execute`, so a reasoning error at the coordination layer cannot become a bad write — every change still passes through an agent with its own limits.
- **`execute` without `edit` separates detection from remediation.** The security-scanner can run checks but cannot remove the control it just flagged, so every security fix passes through something a human reviews.

### MCP configuration traps

- Custom agent YAML uses `mcp-servers`; repository `.mcp.json` uses `mcpServers`; **VS Code's `.vscode/mcp.json` uses plain `servers`**. Three spellings of the same idea, and the wrong one fails silently — the server simply never loads.
- A local process has `command` and `args`. A remote HTTP or SSE server has a `url`.
- A URL passed *inside* a local command's arguments does not make the transport remote. This is the distinction questions are built on.
- Read access to issue context does not imply permission to merge pull requests. Allow-lists are per operation, not per server.

### Cloud-agent setup

| Rule | Consequence if broken |
| --- | --- |
| Filename exactly `copilot-setup-steps.yml` | Silently ignored |
| Job named `copilot-setup-steps` | Silently ignored |
| Present on the **default branch** | Never triggers |
| Only `steps`, `permissions`, `runs-on`, `services`, `snapshot`, `timeout-minutes` | Other keys silently ignored |
| `timeout-minutes` ≤ 59 | Capped |

**A failing setup step does not block the agent.** Copilot skips the rest of setup and works anyway, in a partially prepared environment. Expect exam answers that claim the run halts — they are wrong.

### The three agent file types

| File | Defines | Runs |
| --- | --- | --- |
| `.github/agents/*.agent.md` | Who an agent is — persona and tool list | When you select it |
| `.github/workflows/*.yml` | Conventional CI automation | On its trigger |
| `.github/workflows/*.md` | An AI task — trigger, tools, and safe outputs | On its trigger, after `gh aw compile` |

- Agentic workflows compile to `.lock.yml`; the compiled file is what Actions runs. Commit both.
- `gh aw validate` checks frontmatter without writing; `gh aw compile` writes the lock file.
- `gh aw add` and `gh aw add-wizard` install workflows from other repositories — read their `tools:` and `safe-outputs:` before compiling.
- `safe-outputs` declares which write actions are permitted. The agent's own permissions can stay read-only.
- `engine` selects the model provider — Copilot, Claude, Codex, Gemini, or Pi.

### Where each artifact lives

| Artifact | Scope |
| --- | --- |
| `.github/copilot-instructions.md` | Entire repository |
| `.github/instructions/*.instructions.md` | Specific paths, via an `applyTo` glob |
| `AGENTS.md` | Agent-oriented docs, read by multiple agent tools |
| `.github/agents/*.agent.md` | One agent profile |
| `.mcp.json`, `.github/mcp.json`, `.vscode/mcp.json` | MCP servers, at repository or editor scope |

---

## What you built

Four agents with deliberately graduated capability, a read-only MCP configuration, and a seventh execution boundary, a cloud-agent environment you ran real work in, and an agentic workflow.

**Next:** [Lab 03 — Manage Memory, State, and Execution](03-memory-state-execution.md)
