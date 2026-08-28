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
| 6 | `templates/agent-task-brief.md` | Execution boundaries, including the gateway |
| 7 | `.github/workflows/copilot-setup-steps.yml` | Cloud-agent environment |

**Prerequisite:** [Lab 01](01-agent-architecture-sdlc.md) complete.

**Time:** About 45 minutes

**Environment:** Step 8 reads the deployment in [infra/main.bicep](../infra/main.bicep), which ships the same cart code your agents review. You do not need it deployed — the template is the teaching material. [Lab 00, section 5](00-lab-preparation.md#5-deploy-the-cart-api-optional) has the procedure if you want a live endpoint.

---

## Why this lab comes second

Lab 01 produced one set of instructions for every agent. That works until you want an agent that reviews code *without* being able to change it, and another that must change code to do its job at all. Those are contradictory requirements, and no single configuration satisfies both.

Custom agents resolve it. Each file describes one role: a persona, responsibilities, and — the part that matters — an explicit tool list. The tool list is not a hint. It is the boundary of what the agent can physically do.

---

## The architecture principle

Grant the smallest useful tool set, then restrict where those tools may operate.

```text
tool access -> allow-list -> execution boundaries -> evidence
```

An allow-list says what exists. Boundaries say where it is safe to act. Evidence shows what actually happened.

### Separate the controls

| Control | What it answers |
| --- | --- |
| Tool list on an agent | What can this agent physically do? |
| MCP allow-list | Which external tools are reachable at all? |
| Execution boundaries | Where may the agent act? |
| Error handling | What happens when something fails? |

### The capability progression

The four agents you build form a deliberate ladder:

```text
reviewer          read, search                    -> can look, cannot touch
test-runner       read, search, edit, execute     -> can write and run
security-scanner  read, search, execute           -> can run and inspect, cannot fix
orchestrator      read, search, agent             -> can delegate, cannot act directly
```

The orchestrator sits at the top and is *less* capable than the test-runner in raw terms. Coordination authority and execution authority are separated on purpose: a coordinator that cannot edit files cannot cause damage through a reasoning error. The worst it can do is ask the wrong agent, and that agent's own limits still apply.

---

## Anatomy of an agent file

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

### Why this shape

**The tool list is the actual guarantee.** The body says "do not edit files," but that is a request the model could rationalize around. The absence of `edit` from the tool list is enforced by the runtime. Write both: the instruction explains the intent, the tool list makes it true. When an exam question asks how you *guarantee* an agent cannot modify code, the answer is the tool list, not the prompt.

**The checklist reflects this repository.** Items 3 and 5 are not generic review advice — they map to rules in your `.github/copilot-instructions.md`. A reviewer whose checklist mirrors your conventions produces findings you care about.

**Verify:**

```bash
test -s .github/agents/reviewer.agent.md && echo "PASS: file non-empty"
grep -q "description:" .github/agents/reviewer.agent.md && echo "PASS: has description"
grep -qE "^  - (edit|execute)" .github/agents/reviewer.agent.md \
  && echo "FAIL: reviewer must not have edit or execute" \
  || echo "PASS: read-only"
```

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

### Why this agent gets `execute`

An agent is far more useful when it can close its own feedback loop: make a change, run the tests, see the failure, correct it. That only works with `execute`. Note the command names the exact invocation — a bare `python3 -m unittest` from the wrong directory fails on the import, and an agent that has been told the precise command does not waste turns discovering that.

The constraint about not weakening assertions is not decoration. Left unconstrained, the shortest path from a failing test to a passing suite is deleting the assertion, and an agent optimizing for "tests pass" will find it.

**Verify:**

```bash
test -s .github/agents/test-runner.agent.md && echo "PASS: file non-empty"
grep -q "python3 -m unittest discover -s tests" .github/agents/test-runner.agent.md \
  && echo "PASS: names the real command"
```

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
3. Check whether `infra/main.bicep` changed in a way that widens exposure — a broader
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

### Why it can execute but not edit

This is the combination people find surprising, and it is the point of the exercise. The scanner needs `execute` to run checks, but giving it `edit` would let a single agent both decide a control is wrong and remove it. Separating detection from remediation means every security fix passes through something a human can review.

**Verify:**

```bash
test -s .github/agents/security-scanner.agent.md && echo "PASS: file non-empty"
grep -qE "^  - edit" .github/agents/security-scanner.agent.md \
  && echo "FAIL: scanner must not have edit" \
  || echo "PASS: cannot remediate"
```

---

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

### Why the coordinator is deliberately weak

The orchestrator has `agent` but not `edit` or `execute`. Every change it causes happens through an agent whose own limits still apply, so a reasoning error at the coordination layer cannot translate directly into a bad write. This is the multi-agent pattern Lab 05 builds on.

**Verify:**

```bash
for f in reviewer test-runner security-scanner orchestrator; do
  test -s ".github/agents/$f.agent.md" \
    && echo "PASS: $f" || echo "FAIL: $f missing or empty"
done
```

---

## Step 5 — Configure MCP servers

**Create this file:** `.mcp.json`

```json
{
  "mcpServers": {
    "github": {
      "type": "local",
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-e", "GITHUB_PERSONAL_ACCESS_TOKEN",
        "ghcr.io/github/github-mcp-server"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "$GITHUB_TOKEN"
      },
      "tools": [
        "get_file_contents",
        "list_issues",
        "get_pull_request",
        "list_workflow_run_artifacts"
      ]
    }
  }
}
```

Every tool in that list is a read. Nothing here can comment, merge, approve, or push.

### The allow-list decision

The `tools` array is the allow-list, and omission is denial. Compare it against the fuller design in [tools/mcp.allow-list.example.json](../tools/mcp.allow-list.example.json), which sorts operations into allowed, requires-approval, and denied.

Then answer the question that file cannot answer on its own: **where is each category enforced?**

| Category | Enforced by | Enforced where |
| --- | --- | --- |
| Allowed | The `tools` array in `.mcp.json` | Client, at tool-load time |
| Denied | Omission from that array | Client, at tool-load time |
| Requires approval | ? | ? |

Fill in the last row. There is no `requiresHumanApproval` key in `.mcp.json` — the concept exists in your design document and nowhere in your configuration. Write down which control actually implements it. Lab 06 builds that control; this is the gap it fills.

**Verify:**

```bash
test -s .mcp.json && python3 -m json.tool .mcp.json > /dev/null \
  && echo "PASS: .mcp.json is valid JSON"
grep -qE '"(merge_pull_request|create_or_update_file|delete_)' .mcp.json \
  && echo "FAIL: write tool in the allow-list" \
  || echo "PASS: read-only tool set"
```

> **Never commit a token.** The `env` block references `$GITHUB_TOKEN` from your environment. If you paste a literal token here, secret scanning will flag it and you will be rotating a credential instead of doing Lab 03.

---

## Step 6 — Define execution boundaries

Update [templates/agent-task-brief.md](../templates/agent-task-brief.md) so its **Execution boundaries** section covers all seven scopes. Six are already there. Add the seventh:

```markdown
### Gateway environment

- Reach MCP tools only through the endpoint named in this brief.
- Do not change `allowedIpAddressRange`, ingress settings, or probe configuration in `infra/main.bicep` as part of a task.
- Do not replace `cartApiImage` with a moving tag; the deployed build must stay identifiable.
- Do not add environment variables or secrets to the container definition.
- Treat `infra/` as sensitive, the same as `.github/`, `tools/`, and `infra/`.
```

Write each boundary as a rule the agent can follow, not as a suggestion.

**Verify:**

```bash
grep -q "### Gateway environment" templates/agent-task-brief.md \
  && echo "PASS: gateway boundary present"
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

### Setup prepares; it does not validate

The version in this repository deliberately does **not** run the test suite. That is not an oversight. Setup steps exist to make the environment usable; the agent runs tests itself once it is working. A failing test in setup means the agent's environment never becomes ready, which turns an ordinary red test into a total outage for the agent.

### Why this file is nearly empty here

`app/` and `tests/` import only `dataclasses` and `unittest` — both standard library. There is no `requirements.txt`, so there is nothing to install.

That is the lesson: **the value of this file scales with your dependency surface.** In a repository with third-party packages, a missing install step here is the single most common reason a cloud agent behaves differently from a local one — it reports failures that come from the environment rather than from the code, and Lab 04 asks you to classify exactly that kind of failure.

**Verify:**

```bash
python3 -c "import yaml; d=yaml.safe_load(open('.github/workflows/copilot-setup-steps.yml')); \
  assert 'copilot-setup-steps' in d['jobs'], 'job name must be copilot-setup-steps'; \
  print('PASS: job correctly named')"
```

---

## Step 8 — Read the environment you are securing

No file to create. [infra/main.bicep](../infra/main.bicep) deploys the cart API — the same code your agents review and test — to Azure Container Apps. Open it and map each control to what it enforces:

| Line in the template | What it controls |
| --- | --- |
| `ingressTargetPort: 8000` | The only port reachable from outside |
| `ingressAllowInsecure: false` | HTTPS only; plain HTTP is refused |
| `ipSecurityRestrictions` with one `Allow` rule | Every source address except the reviewed CIDR is denied |
| `cartApiImage` supplied per deployment | The running build is a specific commit, not a moving tag |
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
| `403` from the API URL | Your address is outside `allowedIpAddressRange` | ? |
| Connection refused on plain `http://` | `ingressAllowInsecure: false` working as designed | ? |
| First request takes several seconds | Cold start from `minReplicas: 0` | ? |
| Revision never becomes ready | Startup probe failing on `/healthz` | ? |
| `ImagePullBackOff` | The ghcr.io package is private, or the reference is wrong | ? |

An agent widening a CIDR to clear its own `403` is the failure this lab exists to prevent. Note also which symptoms are indistinguishable from outside: a `403` and a service that never started both look like "it's broken" to the agent, and they need opposite responses.

### Why this matters for Lab 04

The deployed service runs the same `app/cart.py` that `tests/test_cart.py` covers. That is what makes a passing test suite evidence about something real rather than a claim about a local checkout — and Lab 04 asks you to fill an Evidence column with exactly that kind of link.

---

## Self-check

You completed the lab if you can explain:

- Why the tool list, not the prompt, is what guarantees the reviewer cannot edit
- Why the orchestrator is deliberately less capable than the test-runner
- Why the security-scanner has `execute` but not `edit`
- Which part of your MCP allow-list is actually enforced, and which part is only documented
- Why an explicit image reference is an execution boundary and not just a deployment detail
- What breaks first if the allowed CIDR is the only control protecting an unauthenticated service

---

## Exam notes

- GH-600 questions in this domain combine tool choice with execution scope. The best answer usually separates tool selection, approval, and execution boundaries.
- Watch for answers that grant broad permissions, bypass pull requests, expose secrets, or let agents modify governance files without review.
- **Instructions guide; tool lists enforce.** If a question asks how you *guarantee* a capability is absent, the answer is never "tell the agent not to."
- `description` is the field a delegating agent reads. A vague description is why an orchestrator picks the wrong specialist.

### MCP configuration traps

- Custom agent YAML uses `mcp-servers`; JSON configuration uses `mcpServers`. The hyphen is the tell.
- A local process has `command` and `args`. A remote HTTP or SSE server has a `url`.
- A URL passed *inside* a local command's arguments does not make the transport remote. This is the distinction questions are built on.
- Read access to issue context does not imply permission to merge pull requests. Allow-lists are per operation, not per server.

### Where each artifact lives

| Artifact | Scope |
| --- | --- |
| `.github/copilot-instructions.md` | Entire repository |
| `.github/instructions/*.instructions.md` | Specific paths, via an `applyTo` glob |
| `AGENTS.md` | Agent-oriented docs, read by multiple agent tools |
| `.github/agents/*.agent.md` | One agent profile |
| `.mcp.json`, `.github/mcp.json`, `.vscode/mcp.json` | MCP servers, at repository or editor scope |

---

## Common pitfalls

**The tool list and the prose disagree.** If the body says "read-only" and the list includes `edit`, the list wins. Keep them consistent.

**The allow-list is mistaken for enforcement.** A JSON file in `tools/` denies nothing. Name the control that does the denying.

**The boundaries are suggestions.** Write rules, not advice.

**The fix for a boundary is widening the boundary.** Adding your IP to the CIDR to clear a `403` is a governance change wearing the costume of a bug fix.

**A token pasted into `.mcp.json`.** Reference the environment variable instead.

---

## What you built

Four agents with deliberately graduated capability, a read-only MCP configuration, and a seventh execution boundary covering the deployed gateway — each tied to the real code in `app/` and the real template in [infra/main.bicep](../infra/main.bicep) rather than to a hypothetical environment.

**Next:** [Lab 03 — Manage Memory, State, and Execution](03-memory-state-execution.md)
