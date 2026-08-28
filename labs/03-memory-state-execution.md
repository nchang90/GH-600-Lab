# Lab 03 — Memory, State & Execution (Domain 3)

## Introduction

Learn where agent state belongs, how sessions resume, and how to preserve context across environments.

**Estimated time:** 25 minutes

**Microsoft Learn alignment:** [Memory, State, and Evaluation](https://learn.microsoft.com/en-us/training/modules/memory-state-evaluation/)

## Learning objectives

After completing this lab, you'll be able to:

- Distinguish session state, durable artifacts, repository instructions, and Copilot Memory.
- Identify new and resumed sessions from logs.
- Preserve and revalidate state across environments.
- Correct context drift.

## Prerequisites

- Complete [Lab 02b — Tools, MCP, and Environments](02b-tools-mcp-environments.md).

## Lab scenario

An agent task moves between an IDE, CLI, and cloud runner. Decide what can remain in a session and what must be stored as durable, reviewable state.

**Lab output:** No files are created.

## State types

| State | Best location | Survives |
| --- | --- | --- |
| Current conversation | Session log | The same resumed session |
| Decisions and handoffs | PR, issue, job output, or artifact | Sessions and machines |
| Team rules | Repository instructions | Every agent session |
| Personal or inferred facts | Copilot Memory | Sessions until revalidation or expiry |

## Exercise 1 — Read a session log

```text
2026-08-25T08:31:03Z session.id=run-42 cwd=/workspace/GH-600Lab
2026-08-25T08:31:15Z tool=search args="copilot-instructions"
2026-08-25T08:31:20Z tool=read args=".github/copilot-instructions.md"
2026-08-25T08:31:25Z tool=edit args="labs/03-memory-state-execution.md"
2026-08-25T08:31:30Z tool=execute args="python3 -m unittest discover -s tests"
```

Answer:

1. Is this a new or resumed session?
2. What autonomy level does it show?
3. What tool sequence did it use?

<details>
<summary>Answers</summary>

1. **New.** There is no `resume=true` or line loading `events.jsonl`.
2. **Medium.** It used search, read, edit, and execute.
3. **search → read → edit → execute.**

</details>

## Exercise 2 — Choose the correct storage

Match each scenario to a location:

| Scenario | Location |
| --- | --- |
| Continue the same session later | ? |
| Share a plan between workflow jobs | ? |
| Preserve a review decision | ? |
| Store a team-wide convention | ? |
| Audit what an agent did | ? |

<details>
<summary>Answers</summary>

| Scenario | Location |
| --- | --- |
| Continue the same session later | Session ID with `--resume` or `--continue` |
| Share a plan between workflow jobs | Job output or workflow artifact |
| Preserve a review decision | PR comment or review |
| Store a team-wide convention | Repository instructions |
| Audit what an agent did | Session logs and PR timeline |

</details>

## Exercise 3 — Inspect Copilot Memory

1. Open [Copilot Memory settings](https://github.com/settings/copilot/memory).
2. Check whether Memory is enabled.
3. Review its citations and remove any stale entry.

Choose the correct location:

- Personal preference such as spelling style → **Copilot Memory**
- Team rule such as “every endpoint needs a test” → **repository instructions**

Copilot Memory can expire or be disabled. Do not use it as the only home for a team rule.

## Exercise 4 — Move state between environments

Decide where these facts should come from:

| Fact | Source |
| --- | --- |
| Approved discount behavior | Issue or PR description |
| Current branch | Git checkout |
| Test command | Repository instructions |
| Changed files | `git diff` |
| `GITHUB_TOKEN` | The current environment's trust relationship |

Before resuming elsewhere, revalidate:

- Objective and approved scope
- Current branch and changed files
- Recorded decisions
- Completed validation
- Open risks

### Context drift

Context drift occurs when an agent continues using stale assumptions. Start a fresh session, reread current repository state, and store repeated corrections in repository instructions.

## Check your understanding

- A resumed session shows `resume=true` and loads `events.jsonl`.
- Durable state belongs in PRs, issues, logs, outputs, or artifacts—not chat history.
- Derive facts such as branch and changed files instead of carrying them in conversation.
- Use repository instructions for rules that must be shared and reviewable.

## Summary

You identified where state belongs, read a session log, selected durable storage, and prepared to resume work safely across environments.

**Next:** [Lab 04 — Perform Evaluation, Error Analysis, and Tuning](04-evaluation-error-analysis-tuning.md)
