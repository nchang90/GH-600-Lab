# Lab 03 — Memory, State & Execution (Domain 3)

## Introduction

Use real Copilot Chat sessions to observe what survives a resumed session, what a fresh session must reconstruct, and which facts belong in durable repository state.

**Estimated time:** 30 minutes

**Microsoft Learn alignment:** [Memory, State, and Evaluation](https://learn.microsoft.com/en-us/training/modules/memory-state-evaluation/)

## Learning objectives

After completing this lab, you'll be able to:

- Distinguish session state, durable artifacts, repository instructions, and Copilot Memory.
- Resume a session without treating chat history as the system of record.
- Reconstruct task state in a fresh session.
- Revalidate facts that can drift between environments.

## Prerequisites

- Complete [Lab 02b — Tools, MCP, and Environments](02b-tools-mcp-environments.md).
- Complete `agent-task-brief.md`.
- Open this repository in VS Code with Copilot Chat available.

## Lab scenario

The loyalty-discount task moves from one agent session to another. You must preserve enough state for a fresh agent to continue safely without copying the entire conversation.

**Lab output:** `agent-state-record.md`

## State types

| State | Best location |
| --- | --- |
| Current reasoning and temporary names | Resumable session |
| Task decisions and handoffs | Issue, pull request, or repository artifact |
| Shared team rules | `.github/copilot-instructions.md` |
| Personal or inferred facts | Copilot Memory, with citations and revalidation |
| Branch, files, and environment | Derive again from the current environment |

---

## Exercise 1 — Start an agent session

Create `agent-state-record.md` in the repository root:

```markdown
# Agent State Record

## Initial session

## Resumed session

## Fresh-session handoff

## State decisions

| Fact | Storage location | How to revalidate |
| --- | --- | --- |
```

Select **+** at the top of Copilot Chat to create a separate chat, then enter:

```text
Read agent-task-brief.md and .github/copilot-instructions.md. Do not edit files.
Report the task objective, approved file scope, test command, current branch,
and changed files. Cite a file or command as the source of every fact.
```

Copy the response into **Initial session**. Remove any conversational filler, but keep the cited evidence.

---

## Exercise 2 — Resume the agent session

In the same chat, enter the following prompt:

```text
call the loyalty-discount task "Project Lantern".
Do not write that name to a file.
```

Open another chat, then return to this conversation from the chat history. Ask:

```text
What temporary name did I give this task, and where is that fact stored?
```

Record the answer under **Resumed session**. The resumed conversation can use its history, but the temporary name is not durable repository state.

---

## Exercise 3 — Start a fresh agent handoff

Select **+** again to create another separate chat. First ask:

```text
What temporary name did I give the loyalty-discount task?
```

A fresh session should not rely on that unstored fact. If Copilot supplies an answer, ask for its source and treat it as untrusted until verified.

Run the Exercise 1 prompt in the fresh chat. Under Fresh-session handoff, record which facts came from repository files or Git and which facts could not be verified.

---

## Exercise 4 — Place and revalidate state

Complete the **State decisions** table for these facts:

```
| Fact | Storage location | How to revalidate |
| --- | --- | --- |
| Approved discount behavior | `agent-task-brief.md` or approved issue/PR | Reread the approved requirement |
| Allowed files | `agent-task-brief.md` | Reread the scope and run `git diff --name-only` |
| Test command | `.github/copilot-instructions.md` | Reread the instructions and run the command |
| Current branch | Git/current environment | Run `git branch --show-current` |
| Changed files | Git/current environment | Run `git status --short` |
| Project Lantern | Original session context only | Resume the original conversation |
| Credentials or tokens | Secure environment or secret store | Confirm availability without displaying the value |
---
```
## Exercise 5 — Inspect Copilot Memory

Open [Copilot Memory settings](https://github.com/settings/copilot/memory).

If Memory is available, inspect one entry and record its citation, whether it is still valid, and whether you kept or deleted it. If it is unavailable, record `Memory not available for this account`.

Copilot Memory can expire or contain stale inferences. It is not the only home for a team rule or approval decision.

---

## Check your work

```bash
if test -s agent-state-record.md; then
  echo "PASS: agent-state-record.md exists and is not empty"
else
  echo "FAIL: agent-state-record.md is missing or empty"
  exit 1
fi

for heading in \
  "Initial session" \
  "Resumed session" \
  "Fresh-session handoff" \
  "State decisions"; do
  if grep -q "^## $heading$" agent-state-record.md; then
    echo "PASS: $heading"
  else
    echo "FAIL: missing $heading"
    exit 1
  fi
done
```

Review the record and confirm that every durable fact has a source and every environment-dependent fact has a revalidation method.

## Exam preparation

- Resuming a session restores conversational context; it does not make that context durable evidence.
- Fresh sessions reconstruct state from repository files, GitHub artifacts, and the current environment.
- Repository instructions are shared and versioned. Copilot Memory is inferred and must be revalidated.
- Context drift occurs when an agent continues from stale branch, file, environment, or task assumptions.

## Summary

You compared resumed and fresh sessions, created a durable state record, and defined how another agent can revalidate the task before continuing.

**Next:** [Lab 04 — Perform Evaluation, Error Analysis, and Tuning](04-evaluation-error-analysis-tuning.md)
