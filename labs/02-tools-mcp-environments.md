# Lab 02 - Implement Tool Use and Environment Interaction

**Goal:** Give the agent a clear tool set, an MCP allow-list decision, execution boundaries, and an error-handling playbook.

**You will create:**

- `.github/submissions/tool-inventory.md`
- `.github/submissions/mcp-allow-list-decision.md`
- updates to `templates/agent-task-brief.md`
- `.github/submissions/error-handling-runbook.md`

**Time:** About 20 minutes

---

## Why this lab comes second

An agent can only work safely if it knows which tools it may use, which tools need approval, and which execution boundaries still apply even when a tool is allowed.

Tool choice, permissions, and execution scope are separate controls. If you blur them together, an allowed tool can still be used too broadly.

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
| Tool inventory | What tools exist? |
| Allow-list | Which tools are allowed, denied, or approved? |
| Execution boundaries | Where may the agent act? |
| Error handling | What happens when something fails? |

---

## Step 1 - Build the tool inventory

Create `.github/submissions/tool-inventory.md`.

Use this table:

| Tool | Purpose | Required permission | Risk | Allowed for autonomous use? |
| --- | --- | --- | --- | --- |

Include at least:

- Repository file read
- Branch creation
- Pull request creation
- GitHub Actions log read
- Issue comment write
- Secret read
- Environment approval
- MCP tool for project tracking

Use the sample answer in [solutions/lab-02-sample-tool-inventory.md](../solutions/lab-02-sample-tool-inventory.md) only after you have attempted your own version.

---

## Step 2 - Configure an MCP allow-list decision

Copy tools/mcp.allow-list.example.json into your decision file, then adjust the allowed, denied, and approval lists to match your org policy.

---

## Step 3 - Define execution boundaries

Update [templates/agent-task-brief.md](../templates/agent-task-brief.md) with boundaries for:

- Repository scope
- Branch scope
- Workflow scope
- Runner environment
- Network access
- Secrets and variables

Write each boundary as a rule the agent can follow, not as a suggestion.


```
### Repository scope

- Work only in the repository named in this brief.
- Do not change files outside the approved file list.
- Treat `.github/`, `policies/`, and `tools/` as sensitive and do not edit them unless they are explicitly listed as in scope.

### Branch scope

- Use only the branch named in this brief.
- Do not merge, rebase, or rename branches unless the brief says to.
- Do not create or modify release or protected branches.

### Workflow scope

- Use only the workflows named in this brief.
- Do not change workflow permissions, required checks, or job conditions unless the brief explicitly allows it.
- Do not bypass review or approval gates.

### Runner environment

- Use only the runner environment named in this brief.
- Do not assume extra tools, packages, or secrets are available.
- Do not change runner configuration unless the brief explicitly allows it.

### Network access

- Use only the network access explicitly allowed in this brief.
- Do not reach external services unless the brief names them.
- Prefer local repository evidence over network calls when the brief does not require external data.

### Secrets and variables

- Use only the secrets and variables named in this brief.
- Do not read, print, copy, or invent secret values.
- Do not add new secrets or variables unless the brief explicitly allows it.

```

---


## Self-check

You completed the lab if you can explain:

- Why tool access should be granted by purpose, not convenience
- How MCP allow-lists reduce blast radius
- Why agent access to secrets should be exceptional
- Why branch and workflow scope are separate controls
- What evidence proves a tool action happened

---

## Exam notes

- GH-600 questions in this domain often combine tool choice with execution scope.
- Watch for answers that grant broad permissions, bypass pull requests, expose secrets, or let agents modify governance files without review.
- The best answer usually separates tool selection, approval, and execution boundaries.

---

## Common pitfalls

**The inventory is too vague.** Name the permission and risk for each tool.

**The allow-list is too permissive.** Deny secrets and approvals unless the task explicitly requires them.

**The boundaries are suggestions.** Write rules, not advice.

**The runbook is generic.** Include concrete retry, rollback, and escalation decisions.

---

## What you built

You created one tool inventory, one MCP allow-list decision, one execution-boundary update, and one error-handling runbook.

**Next:** Move to [Lab 03 - Manage Memory, State, and Execution](03-memory-state-execution.md).
