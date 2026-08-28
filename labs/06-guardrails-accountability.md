# Lab 06 — Guardrails & Accountability (Domain 6)

## Introduction

Add preventive and detective controls for agent actions, then map each risk to the correct GitHub control.

**Estimated time:** 35 minutes

**Microsoft Learn alignment:** [Governance, guardrails, and operations](https://learn.microsoft.com/en-us/training/modules/governance-guardrails-operations/)

## Learning objectives

After completing this lab, you'll be able to:

- Block dangerous commands before execution.
- Record edits for audit.
- Require evidence in pull requests.
- Apply least privilege and human approval.
- Maintain controls over time.

## Prerequisites

- Complete [Lab 05 — Multi-Agent Coordination](05-multi-agent-coordination.md).

## Lab scenario

Your agents can review changes, but the repository needs controls that prevent unsafe actions, preserve evidence, and remain current.

## Exercise 1 — Configure hooks

Create `.github/hooks/pre-tool-policy.json`:

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

`preToolUse` can block an action. `postToolUse` runs after the action and can only report context.

## Exercise 2 — Block dangerous commands

Create `.github/hooks/scripts/pre-tool-policy.sh`:

```bash
#!/bin/bash
INPUT=$(cat)
TOOL_ARGS=$(echo "$INPUT" | jq -r '.toolArgs // empty')

if echo "$TOOL_ARGS" | grep -q "git push.*main\|git push.*prod"; then
  echo '{"permissionDecision":"deny","permissionDecisionReason":"Open a pull request instead."}'
elif echo "$TOOL_ARGS" | grep -q "git push.*--force\|git push.*-f"; then
  echo '{"permissionDecision":"deny","permissionDecisionReason":"Force push is not allowed."}'
elif echo "$TOOL_ARGS" | grep -qiE "(password|secret|token|api.key)="; then
  echo '{"permissionDecision":"deny","permissionDecisionReason":"Potential secret detected."}'
elif echo "$TOOL_ARGS" | grep -q "rm -rf /\|rm -rf \.\|rm -rf \*"; then
  echo '{"permissionDecision":"deny","permissionDecisionReason":"Destructive delete is not allowed."}'
else
  echo '{"permissionDecision":"allow"}'
fi
```

Make it executable:

```bash
chmod +x .github/hooks/scripts/pre-tool-policy.sh
```

## Exercise 3 — Record edits

Create `.github/hooks/scripts/post-edit-check.sh`:

```bash
#!/bin/bash
cat > /dev/null
echo '{"context":"Edit recorded. Run tests to verify changes."}'
```

```bash
chmod +x .github/hooks/scripts/post-edit-check.sh
```

This is a detective control: the edit already occurred.

## Exercise 4 — Add a pull request template

Create `.github/PULL_REQUEST_TEMPLATE.md`:

```markdown
## What changed

## Why

## Evidence

| Signal | Result | Where to check |
| --- | --- | --- |
| Unit tests | | |
| Changed file scope | | |
| Plan adherence | | |
| Human review | | |

## Scope

- [ ] Changes match the task brief
- [ ] Sensitive-path changes are explicitly in scope
- [ ] No test or validation guard was removed
- [ ] No credentials, tokens, or secrets are included

## Authored by

- [ ] Human
- [ ] Agent — name the agent and include a `Co-authored-by` trailer
```

A template requests evidence; it does not enforce policy. Rulesets and required checks enforce merge requirements.

## Exercise 5 — Maintain governance

Record this cadence in `.github/copilot-instructions.md` or a team runbook:

| Cadence | Review |
| --- | --- |
| Weekly | Failed runs and repeated violations |
| Monthly | Workflow permissions and secret scopes |
| Quarterly | Rulesets, CODEOWNERS, reviewers, and artifact retention |

Add a `## Non-goals` section to `agent-task-brief.md`. A safe task states what the agent must not change.

When retiring an agent, also update its owner, orchestrator delegation rules, workflow matrices, and hook rules.

## Exercise 6 — Match risks to controls

| Risk | Control |
| --- | --- |
| Unreviewed merge to `main` | Branch protection or ruleset |
| Production deployment | Protected environment with required reviewer |
| Hardcoded secret | Secret scanning and push protection |
| Vulnerable dependency | Dependency review |
| Agent runs `git push` | `preToolUse` hook plus branch protection |
| Deleted artifact | Organization audit log |
| Agent session activity | Session logs and PR timeline |

## Check your work

```bash
python3 -m json.tool .github/hooks/pre-tool-policy.json > /dev/null

for script in pre-tool-policy post-edit-check; do
  test -x ".github/hooks/scripts/$script.sh"
done

echo '{"toolName":"bash","toolArgs":"git push origin main"}' \
  | .github/hooks/scripts/pre-tool-policy.sh

echo '{"toolName":"bash","toolArgs":"python3 -m unittest discover -s tests"}' \
  | .github/hooks/scripts/pre-tool-policy.sh
```

The first command must return `deny`; the second must return `allow`.

## Check your understanding

- Preventive controls act before damage; detective controls reveal what happened; corrective controls recover afterward.
- `preToolUse` is the hook event that can block.
- `ask` becomes deny for a noninteractive cloud agent.
- Hooks reduce unsafe actions but do not replace rulesets, branch protection, or protected environments.
- Human approval matters only when the reviewer examines useful evidence.

## Summary

You added preventive hooks, an edit audit signal, a PR evidence template, and a maintenance cadence for governed agent operation.

This completes the lab sequence.
