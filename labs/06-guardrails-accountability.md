# Lab 06 — Guardrails & Accountability

**Goal:** build controls that hold when an agent tries to do something it should not, and understand which layer of the stack each control belongs to.

**You will create:**

| Step | File | Purpose |
| --- | --- | --- |
| 1 | `.github/hooks/pre-tool-policy.json` | Hook configuration |
| 2 | `.github/hooks/scripts/pre-tool-policy.sh` | Deny dangerous commands |
| 3 | `.github/hooks/scripts/post-edit-check.sh` | Audit trail after edits |

**Prerequisite:** [Lab 05](05-multi-agent-coordination.md) complete.

**Time:** About 35 minutes

---

## Three categories of control

Every safety mechanism falls into one of three categories, and knowing which is which is most of Domain 6.

| Category | Acts | Examples |
| --- | --- | --- |
| **Preventive** | Before the action | Tool lists, hooks, branch protection, rulesets |
| **Detective** | After the action | Session logs, CodeQL, secret scanning, audit logs |
| **Corrective** | After the damage | Revert PR, stop session, rotate secrets |

You need all three. Preventive controls fail — a regex misses a case, a rule has an exception. Detective controls tell you it happened. Corrective controls limit how long the damage persists.

The mistake to avoid is investing entirely in prevention and having no idea when it fails.

---

## The enforcement ladder

```text
Instructions      guide behaviour        not enforceable
Tool lists        bound capability       enforced by the runtime
Hooks             intercept actions      can deny at execution time
Branch protection  enforce policy        cannot be bypassed
```

Each rung is stronger and more expensive than the one below. Match the rung to the consequence: a style preference belongs in instructions; "never force-push to main" belongs at the top, enforced in two places.

---

## What a hook is

A hook is a script that runs at a defined point in the agent's execution and returns a decision. The one that matters is `preToolUse`, which fires **before** a tool executes and can block it.

The contract is simple: JSON on stdin describing the intended action, JSON on stdout with the decision.

```text
stdin  → {"toolName": "bash", "toolArgs": "git push origin main"}
stdout → {"permissionDecision": "deny", "permissionDecisionReason": "..."}
```

Three decisions are possible:

| Decision | Interactive session | Cloud agent |
| --- | --- | --- |
| `allow` | Tool executes | Tool executes |
| `deny` | Tool blocked | Tool blocked |
| `ask` | User is prompted | **Treated as deny** |

`ask` becomes `deny` in a cloud agent. There is no user present to answer, so the safe default is refusal.

### The other hook events

`preToolUse` is the one you build in this exercise, because it is the only event that can **block** an action. It is not the only event available. You will not configure these, but you should recognise them and know what each is for:

| Event | Fires | Typical use |
| --- | --- | --- |
| `sessionStart` | When a session begins | Inject environment facts the agent cannot discover |
| `userPromptSubmitted` | After the user submits a prompt, before the agent reasons | Redact secrets or reject out-of-scope work |
| `postToolUse` | After a tool succeeds | Run a formatter or linter after an edit, re-run affected tests |
| `errorOccurred` | When a tool or the agent raises an error | Capture diagnostics and decide whether a retry is sane |
| `agentStop` | When the top-level agent finishes | Post the run summary and close out the audit record |
| `subagentStop` | When a delegated sub-agent finishes | Validate a sub-agent's output before the orchestrator consumes it |
| `sessionEnd` | When the session terminates | Flush logs and remove temporary credentials |

Two distinctions worth holding onto:

- **Only `preToolUse` is preventive.** Everything else observes or reacts after the fact, which puts them in the detective and corrective categories.
- **`agentStop` and `subagentStop` are different scopes.** If you want per-agent validation, `agentStop` is too late.

---

## Step 1 — Hook configuration

**Create this file:** `.github/hooks/pre-tool-policy.json`

```json
{
  "version": 1,
  "hooks": {
    "preToolUse": [
      {
        "type": "command",
        "matcher": "bash|powershell",
        "bash": ".github/hooks/scripts/pre-tool-policy.sh",
        "timeoutSec": 30
      }
    ],
    "postToolUse": [
      {
        "type": "command",
        "matcher": "edit|create",
        "bash": ".github/hooks/scripts/post-edit-check.sh",
        "timeoutSec": 15
      }
    ]
  }
}
```

### The `matcher` field

`matcher` is a regex against the hook's `toolName`, deciding which actions invoke the script. `"bash|powershell"` catches shell execution on either platform. Running the policy script on every file read would be pure overhead — the matcher keeps it targeted.

### Hook tool names are not agent tool names

This is the single most confusing part of Domain 6, and it is heavily tested. The names used in hooks are finer-grained than the capability names in an agent's `tools:` list:

| Hook `toolName` | Agent `tools` entry | Meaning |
| --- | --- | --- |
| `view` | `read` | Read file contents |
| `grep` | `search` | Search file contents |
| `glob` | `search` | Find files by pattern |
| `edit` | `edit` | Modify files |
| `create` | `edit` | Create new files |
| `bash` | `execute` | Run shell commands |
| `task` | `agent` | Run subagent tasks |

Traps:

- `view` means reading a file, not browsing the web.
- `grep` and `glob` both map to `search`.
- `create` requires `edit` in the agent's tools list.

`timeoutSec` bounds how long the hook may take. A hook that hangs would otherwise stall the agent indefinitely.

---

## Step 2 — The policy script

**Create this file:** `.github/hooks/scripts/pre-tool-policy.sh`

```bash
#!/bin/bash
# Pre-tool policy hook
# Blocks dangerous shell commands from being executed by agents
# This runs BEFORE the tool executes — can deny or allow

# Read the tool input from stdin
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName // empty')
TOOL_ARGS=$(echo "$INPUT" | jq -r '.toolArgs // empty')

# Block direct pushes to main/production branches
if echo "$TOOL_ARGS" | grep -q "git push.*main\|git push.*prod"; then
  echo '{"permissionDecision": "deny", "permissionDecisionReason": "Direct push to main/prod is not allowed. Open a pull request instead."}'
  exit 0
fi

# Block force pushes
if echo "$TOOL_ARGS" | grep -q "git push.*--force\|git push.*-f"; then
  echo '{"permissionDecision": "deny", "permissionDecisionReason": "Force push is not allowed. Use a PR-based workflow."}'
  exit 0
fi

# Block secrets/credentials in commands
if echo "$TOOL_ARGS" | grep -qiE "(password|secret|token|api.key)="; then
  echo '{"permissionDecision": "deny", "permissionDecisionReason": "Detected potential secret in command arguments. Use environment variables or secrets."}'
  exit 0
fi

# Block rm -rf on critical paths
if echo "$TOOL_ARGS" | grep -q "rm -rf /\|rm -rf \.\|rm -rf \*"; then
  echo '{"permissionDecision": "deny", "permissionDecisionReason": "Destructive recursive delete is not allowed."}'
  exit 0
fi

# Allow all other commands
echo '{"permissionDecision": "allow"}'
```

Make it executable:

```bash
chmod +x .github/hooks/scripts/pre-tool-policy.sh
```

### What the four rules protect

**Direct push to main/prod** — the agent must go through a pull request.

**Force push** — rewrites history and can destroy other people's commits.

**Secrets on the command line** — command lines land in logs, shell history, and process listings.

**Destructive recursive delete** — self-explanatory, and irreversible.

### Every denial explains itself

`permissionDecisionReason` is returned to the agent, which means it can adapt. A bare denial just produces a retry loop.

**A good guardrail states the allowed alternative.**

### The honest limitation

These are regex checks on a command string, and regexes on shell commands are defeatable. That does not make the hook useless; it makes it one layer. Branch protection is what actually guarantees the push fails, because it is enforced server-side where no clever quoting reaches it.

**Hooks reduce accidents. Branch protection stops the action.**

---

## Step 3 — The post-edit hook

**Create this file:** `.github/hooks/scripts/post-edit-check.sh`

```bash
#!/bin/bash
# Post-edit check hook
# Runs AFTER file edits — adds context about what was changed
# Used for audit trail and drift detection

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName // empty')

# Log the edit for audit purposes
echo '{"context": "Edit recorded for audit trail. Run tests to verify changes."}'
```

```bash
chmod +x .github/hooks/scripts/post-edit-check.sh
```

`postToolUse` runs after the action, so it cannot deny anything — the edit already happened. It returns `context` rather than `permissionDecision`, and that context is injected back into the agent's working state.

This is a detective control, and also a nudge: reminding the agent to run tests after an edit reinforces the `edit → execute` habit.

---

## Task — Match each scenario to its control

| # | Scenario |
| --- | --- |
| 1 | Prevent unreviewed merge to main |
| 2 | Require human approval before production deploy |
| 3 | Detect hardcoded API key in code |
| 4 | Detect vulnerable dependency |
| 5 | Block agent from running `git push` |
| 6 | Know who deleted a workflow artifact |
| 7 | Know what an agent did in a session |

**Options:** A) Branch protection / ruleset · B) Environment required reviewer · C) Secret scanning / push protection · D) Dependency review action · E) `preToolUse` hook + branch protection · F) Audit log (`artifact.destroy`) · G) Session logs + PR timeline

<details>
<summary>Answers</summary>

1. **A — Branch protection / ruleset.**
2. **B — Environment required reviewer.**
3. **C — Secret scanning / push protection.**
4. **D — Dependency review action.**
5. **E — Both.**
6. **F — Audit log, `artifact.destroy` event.**
7. **G — Session logs + PR timeline.**

</details>

Note how the answers distribute across the three categories: 1, 2, 5 are preventive; 3, 4, 6, 7 are detective. Scenario 5 is the only one requiring two layers — because it is the only one where the agent is actively attempting the prohibited action.

---

## Verify

```bash
test -s .github/hooks/pre-tool-policy.json &&
  python3 -m json.tool .github/hooks/pre-tool-policy.json > /dev/null &&
  echo "PASS: valid hook config"

grep -q '"matcher": "bash|powershell"' .github/hooks/pre-tool-policy.json &&
  echo "PASS: matcher targets shell tools"

for s in pre-tool-policy post-edit-check; do
  f=".github/hooks/scripts/$s.sh"
  [ -x "$f" ] && echo "PASS: $s executable" || echo "FAIL: $s not executable — run chmod +x"
done
```

Test the policy script directly by feeding it the JSON a hook would send:

```bash
echo '{"toolName":"bash","toolArgs":"git push origin main"}' \
  | .github/hooks/scripts/pre-tool-policy.sh
# expect: {"permissionDecision": "deny", ...}

echo '{"toolName":"bash","toolArgs":"python3 -m unittest discover -s tests"}' \
  | .github/hooks/scripts/pre-tool-policy.sh
# expect: {"permissionDecision": "allow"}
```

This works because the hook contract is just stdin and stdout — the script is testable without an agent.

---

## Self-check

You completed the lab if you can explain:

- Which of the three control categories each artifact you built belongs to
- Why `ask` is not a safe decision in a cloud agent
- Why the hook and branch protection are both needed for the same rule
- The difference between a hook `toolName` and an agent `tools` entry
- What your hook cannot stop, and which control covers that gap

---

## Exam notes

### Control categories

| Category | Timing | Examples |
| --- | --- | --- |
| Preventive | Before | Tools, hooks, branch protection, rulesets |
| Detective | After | Session logs, CodeQL, secret scanning, audit logs |
| Corrective | After damage | Revert PR, stop session, rotate secrets |

### Hook decisions

```text
"allow" → tool executes
"deny"  → tool blocked (include a reason)
"ask"   → interactive: prompts the user
          cloud agent: treated as DENY
```

### Hook events

| Event | Fires | Can block? |
| --- | --- | --- |
| `sessionStart` | Session begins | No |
| `userPromptSubmitted` | Prompt submitted, before reasoning | No |
| `preToolUse` | **Before** a tool runs | **Yes** |
| `postToolUse` | After a tool succeeds | No |
| `errorOccurred` | Tool or agent errors | No |
| `subagentStop` | A delegated sub-agent finishes | No |
| `agentStop` | The top-level agent finishes | No |
| `sessionEnd` | Session terminates | No |

`preToolUse` is the only preventive hook. If a question asks how to **stop** an action, every other event is the wrong answer.

### Hook toolName → agent capability

| Hook `toolName` | Agent `tools` |
| --- | --- |
| `view` | `read` |
| `grep` | `search` |
| `glob` | `search` |
| `edit` | `edit` |
| `create` | `edit` |
| `bash` | `execute` |
| `task` | `agent` |

Traps:

- `view` is file reading, not web.
- `grep` and `glob` both mean `search`.
- `create` requires `edit`.

### The enforcement ladder

- Instructions guide — not enforceable
- Hooks intercept — can deny
- Branch protection enforces — cannot be bypassed

High-risk actions get multiple layers.

### Audit

- `artifact.destroy` in the organization audit log — who deleted an artifact
- Session logs + PR timeline — what an agent did

### One more accountability gate

When Copilot pushes workflow changes to a PR and the workflows do not run, the fix is to click **"Approve and run workflows."** This is deliberate: an agent editing CI could otherwise grant itself capability by modifying the very workflow that validates it.

---

## Common pitfalls

**Forgetting `chmod +x`.** The hook silently fails to run.

**Assuming `ask` prompts someone in CI.** It denies.

**Confusing hook tool names with agent capabilities.** Different vocabularies, same system.

**Relying on the hook alone for high-risk actions.** Regex is defeatable; add branch protection.

**Denying without a reason.** The agent cannot adapt and will retry.

**Skipping detective controls.** Prevention fails; you need to know when.

---

## What you built

A preventive layer that blocks dangerous commands before they execute, a detective layer that records edits for audit, and a clear model of which control belongs where.

**Next:** This completes the lab sequence.
