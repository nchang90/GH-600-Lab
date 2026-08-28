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

### What a hook cannot stop

Pattern matching on a command string is bypassable — `rm -rf` can be spelled with variables, quoting, or a different tool entirely. A `preToolUse` hook reduces accidents; it does not stop a determined path. Branch protection, rulesets, required checks, and protected environments enforce at the repository and deployment layer, where a shell string cannot reach. Hooks are one rung of the ladder, never the whole ladder.

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

### Audit

- `artifact.destroy` in the organization audit log — who deleted an artifact
- Session logs + PR timeline — what an agent did

### One more accountability gate

When Copilot pushes workflow changes to a PR and the workflows do not run, the fix is to click **"Approve and run workflows."** This is deliberate: an agent editing CI could otherwise grant itself capability by modifying the very workflow that validates it.

---

## What you built

A preventive layer that blocks dangerous commands before they execute, a detective layer that records edits for audit, and a clear model of which control belongs where.

**Next:** This completes the lab sequence.
