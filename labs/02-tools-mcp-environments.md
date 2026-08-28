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
| 6 | `templates/agent-task-brief.md` | Execution boundaries, including the deployment |
| 7 | `.github/workflows/copilot-setup-steps.yml` | Cloud-agent environment |
| 9 | `.github/workflows/test-coverage-review.md` | An agentic workflow |

Step 8 creates nothing — it reads the deployment template that the boundaries in Step 6 protect.

**Prerequisite:** [Lab 01](01-agent-architecture-sdlc.md) complete.

**Time:** About 55 minutes

**Environment:** Step 8 reads the deployment in [infra/resources.bicep](../infra/resources.bicep), which ships the same cart code your agents review. You do not need it deployed — the template is the teaching material. [Lab 00, section 5](00-lab-preparation.md#5-deploy-the-cart-api-optional) has the procedure if you want a live endpoint.

---

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

## Output format

For every finding, report:

- **Severity**: Critical, High, Medium, or Low
- **File**: repository-relative path
- **Finding**: concise explanation
- **Recommendation**: specific remediation

If no defects are found, state that clearly and name the remaining test gaps.
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

## Output format

- **Command**: the exact command run
- **Result**: pass or fail, with counts
- **Diagnosis**: for each failure, the cause and the layer it belongs to
- **Action taken**: what you changed, or why you changed nothing
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

## Output format

- **Severity**: Critical, High, Medium, or Low
- **File and line**
- **Finding**
- **Why it matters**
- **Recommended remediation** (for a human or the test-runner to apply)
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

## Output format

A single consolidated report with one section per delegated agent, then a
**Conflicts** section, then an overall recommendation.
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

If you must run the server locally in Docker, a token is required. Reference it as an input, never inline:

```json
{
  "mcpServers": {
    "github": {
      "type": "local",
      "command": "docker",
      "args": ["run", "-i", "--rm", "-e", "GITHUB_PERSONAL_ACCESS_TOKEN", "ghcr.io/github/github-mcp-server"],
      "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "${input:github_token}" }
    }
  }
}
```

`${input:...}` prompts and stores the value outside the file. A shell-style `$GITHUB_TOKEN` is not interpolated here — it would be passed through as the literal string.

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

**Verify:**

```bash
test -s .mcp.json && python3 -m json.tool .mcp.json > /dev/null \
  && echo "PASS: .mcp.json is valid JSON"

grep -qi "ghp_\|github_pat_\|ghs_" .mcp.json \
  && echo "FAIL: a literal token is in the file" \
  || echo "PASS: no literal token"

python3 -c "
import json; d=json.load(open('.mcp.json'))['mcpServers']['github']
h=d.get('headers',{})
print('PASS: read-only enforced server side' if h.get('X-MCP-Readonly')=='true' or '/readonly' in d.get('url','')
      else 'CHECK: nothing prevents write tools from loading')"
```

**Behavioural test:** ask an agent to merge a pull request through MCP. It should report that no such tool is available — not that it declined. Those are different failures, and only the first is a boundary.

---

## Step 6 — Define execution boundaries

Update [templates/agent-task-brief.md](../templates/agent-task-brief.md) so its **Execution boundaries** section covers all seven scopes. Six are already there. Add the seventh:

```markdown
### Deployment environment

- Reach the cart API and MCP tools only through the endpoints named in this brief.
- Do not change `allowedIpAddressRange`, ingress settings, or probe configuration in `infra/resources.bicep` as part of a task.
- Do not replace `cartApiImage` with a moving tag; the deployed build must stay identifiable.
- Do not add environment variables or secrets to the container definition.
- Treat `infra/` as sensitive, the same as `.github/` and `tools/`.
```

Write each boundary as a rule the agent can follow, not as a suggestion.

**Verify:**

```bash
grep -q "### Deployment environment" templates/agent-task-brief.md \
  && echo "PASS: deployment boundary present"
grep -c "^### " templates/agent-task-brief.md
```

Expected: `7` scope headings under Execution boundaries.

---

## Step 7 — Prepare the cloud-agent environment

**Review this file:** `.github/workflows/copilot-setup-steps.yml`

When Copilot's coding agent works on a pull request, it runs on GitHub's infrastructure, not yours. It reads this file to prepare its environment before starting. Two rules make it work:

- The **filename must be exactly** `copilot-setup-steps.yml`.
- The **job must be named** `copilot-setup-steps`.

Get either wrong and the file is silently ignored — no error, no warning, just an agent working in an unprepared environment.

Setup prepares the environment; it does not validate the code. The version here deliberately does not run the test suite — a failing test in setup would mean the agent's environment never becomes ready, turning an ordinary red test into a total outage for the agent.

**Verify:**

```bash
python3 -c "import yaml; d=yaml.safe_load(open('.github/workflows/copilot-setup-steps.yml')); \
  assert 'copilot-setup-steps' in d['jobs'], 'job must be named copilot-setup-steps'; \
  print('PASS: job correctly named')"
```

## Step 8 — Read the environment you are securing

No file to create. [infra/resources.bicep](../infra/resources.bicep) deploys the cart API — the same code your agents review and test — to Azure Container Apps. Open it and map each control to what it enforces:

| Line in the template | What it controls |
| --- | --- |
| `ingressTargetPort: 8000` | The only port reachable from outside |
| `ingressAllowInsecure: false` | HTTPS only; plain HTTP is refused |
| `ipSecurityRestrictions` with one `Allow` rule | Every source address except the reviewed CIDR is denied |
| `cartApiImage` supplied per environment | The running build is a specific commit, not a moving tag |
| `minReplicas: 0` | No replica runs, and nothing is billed, until a request arrives |
| `env` containing only `PORT` | No credentials are mounted |
| `USER appuser` in the Dockerfile | Execution inside the container cannot modify the image |

Three of these are worth pausing on.

**The API has no authentication.** The template's own comment says the allow rule exists to "limit the unauthenticated lab API." The network restriction is not defence in depth here — it is the *only* control between the internet and the service. That changes how much weight the CIDR carries.

**Scale-to-zero changes what a timeout means.** With `minReplicas: 0`, the first request after an idle period pays a cold start. An agent that treats a slow first response as a failure and retries aggressively will generate load against a service that was working correctly. "Slow" and "broken" are not the same signal.

**The image reference is an execution boundary.** Deploying `:latest` would mean the running code is whatever was pushed last, which makes "the tests passed" a claim about a build you can no longer identify. Passing an explicit commit reference is what lets a test result and a deployment refer to the same thing.

### Failure modes to reason through

For each row, decide the retry rule, the rollback step, and the escalation trigger:

| Symptom | What it usually means | May an agent resolve it alone? |
| --- | --- | --- |
| `403` from the API URL | Your address is outside `ALLOWED_IP_RANGE` | ? |
| Connection refused on plain `http://` | `ingressAllowInsecure: false` working as designed | ? |
| First request takes several seconds | Cold start from `minReplicas: 0` | ? |
| Revision never becomes ready | Startup probe failing on `/healthz` | ? |
| `ImagePullBackOff` | The ghcr.io package is private, or the reference is wrong | ? |

An agent widening a CIDR to clear its own `403` is the failure this lab exists to prevent. Note also which symptoms are indistinguishable from outside: a `403` and a service that never started both look like "it's broken" to the agent, and they need opposite responses.

## Step 9 — Author an agentic workflow

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
gh extension install githubnext/gh-aw   # once
gh aw compile
```

`gh aw compile` turns each `.md` into a hardened `.lock.yml` beside it — that generated file is what Actions actually runs. Commit both. Editing the `.lock.yml` by hand is pointless; the next compile overwrites it.

```bash
test -f .github/workflows/test-coverage-review.md && echo "PASS: agentic workflow present"
grep -q "safe-outputs" .github/workflows/test-coverage-review.md && echo "PASS: outputs are declared"
grep -qE "^\s+contents: write" .github/workflows/test-coverage-review.md \
  && echo "FAIL: agent should not hold write permission" \
  || echo "PASS: read-only permissions"
```

**Behavioural test:** run it with `gh aw run test-coverage-review`, then check the issue it opened. The issue is authored by the workflow, not by you — which is the attribution question Lab 01 Step 4 asked you to trace.

---

## Self-check

You completed the lab if you can explain:

- Why the tool list, not the prompt, is what guarantees the reviewer cannot edit
- Why the orchestrator is deliberately less capable than the test-runner
- Why the security-scanner has `execute` but not `edit`
- Which part of your MCP allow-list is actually enforced, and which part is only documented
- How an agentic workflow can create an issue while holding only read permissions
- Why a server-side read-only header is a stronger control than a client-side tool list
- Why an explicit image reference is an execution boundary and not just a deployment detail
- What breaks first if the allowed CIDR is the only control protecting an unauthenticated service

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

### The three agent file types

| File | Defines | Runs |
| --- | --- | --- |
| `.github/agents/*.agent.md` | Who an agent is — persona and tool list | When you select it |
| `.github/workflows/*.yml` | Conventional CI automation | On its trigger |
| `.github/workflows/*.md` | An AI task — trigger, tools, and safe outputs | On its trigger, after `gh aw compile` |

- Agentic workflows compile to `.lock.yml`; the compiled file is what Actions runs.
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

Four agents with deliberately graduated capability, a read-only MCP configuration, and a seventh execution boundary covering the deployment — each tied to the real code in `app/` and the real template in [infra/resources.bicep](../infra/resources.bicep) rather than to a hypothetical environment.

**Next:** [Lab 03 — Manage Memory, State, and Execution](03-memory-state-execution.md)
