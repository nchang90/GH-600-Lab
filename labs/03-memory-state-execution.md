# Lab 03 — Memory, State & Execution (Domain 3)

## Introduction

In this lab, you analyze where agent state lives, how a session is resumed, and which storage mechanism fits each kind of state.

**Estimated time:** 40 minutes

**Microsoft Learn alignment:** [Memory, State, and Evaluation](https://learn.microsoft.com/en-us/training/modules/memory-state-evaluation/)

## Learning objectives

After completing this lab, you'll be able to:

- Distinguish session state, durable artifacts, repository memory, and Copilot Memory.
- Identify new and resumed sessions from an execution log.
- Select an appropriate storage mechanism for agent state.
- Revalidate state when work moves between environments.
- Recognize and correct context drift.

## Prerequisites

- Complete [Lab 02b — Tools, MCP, and Environments](02b-tools-mcp-environments.md).

## Lab scenario

An agent task may move between sessions, machines, runners, and team members. You need to decide what can remain in session context, what must become a durable artifact, and what must be revalidated before execution continues.

**Lab output:** No files are created. This lab develops analysis and judgment that you apply directly in Labs 04 and 05.

---

## The four kinds of state

| Kind | Lives in | Survives |
| --- | --- | --- |
| **Session state** | Copilot session log | Resuming the same session |
| **Durable artifacts** | PRs, issues, logs, workflow artifacts | Anything — this is the record |
| **Repository memory** | Instruction files in the repo | Every session, for everyone |
| **Copilot Memory** | GitHub, server-side | Across sessions until unused for 28 days |

### Quick rules

- Session state is local to one session ID.
- Durable artifacts are what teammates and CI can actually inspect.
- Repository memory is the durable place for rules that must apply to everyone.
- Copilot Memory is shared, cited, revalidated, and can expire.

---

## Exercise 1 — Read a session log

Read the log and answer the questions below.

```text
2026-08-25T08:31:03Z session.id=run-42 cwd=/workspace/GH-600Lab
2026-08-25T08:31:04Z ide=Visual Studio Code connected
2026-08-25T08:31:05Z mcp loaded ~/.copilot/mcp-config.json servers=[github,playwright]
2026-08-25T08:31:15Z tool=search args="copilot-instructions"
2026-08-25T08:31:20Z tool=read args=".github/copilot-instructions.md"
2026-08-25T08:31:25Z tool=edit args="labs/03-memory-state-execution.md"
2026-08-25T08:31:30Z tool=execute args="python3 -m unittest discover -s tests"
```

**Questions**

1. New session or resumed?
2. What autonomy level does this agent have?
3. What sequence of tools did it use?

<details>
<summary>Answers</summary>

1. **New session.** There is no `resume=true` and no line loading `events.jsonl`.
2. **Medium.** It used `read`, `search`, `edit`, and `execute`.
3. **search → read → edit → execute.**

</details>

## Exercise 2 — Match each scenario to the right storage

Write the matching letter (A–E) next to each number.

**Options:** A) Session ID / session-state · B) Workflow artifact or job output · C) PR comment / review · D) Instructions or repository memory · E) Session logs / PR timeline

| # | Scenario |
| --- | --- |
| 1 | Continue the same agent session later |
| 2 | Share a plan between workflow jobs |
| 3 | Preserve a review decision for audit |
| 4 | Store a long-term repository convention |
| 5 | Track what an agent did and why |

<details>
<summary>Answers</summary>

1. **A — Session ID / session-state.** Use `--resume` or `--continue`.
2. **B — Workflow artifact or job output.** `$GITHUB_OUTPUT` for small values, `upload-artifact` for files.
3. **C — PR comment / review.** Auditable, attributable, visible to every reviewer, and attached to the change it describes.
4. **D — Instructions or repository memory.** Persists across all sessions and all agents.
5. **E — Session logs / PR timeline.** The record of what actually happened.

</details>

## Exercise 3 — Inspect your own Copilot Memory

This one is hands-on, and it takes two minutes.
1. Open **[github.com/settings/copilot/memory](https://github.com/settings/copilot/memory)**.
2. Confirm whether Memory is enabled for your account. If you are on a Business or Enterprise licence and see nothing, the organization policy has not been turned on — note that and move on, it does not block the lab.
3. Read whatever preferences are listed. Each one carries a citation showing what it was inferred from.
4. Delete any entry that is wrong or stale, and notice that you can do this per entry.

**Questions**

1. A teammate's session learned that this repository deploys through `ci.yml` rather than by hand. Will your session know that?
2. You tell Copilot "always use British spelling in comments." Where does that land, and who else is affected?
3. Your team has a rule that every new endpoint needs a test. Copilot Memory or `copilot-instructions.md`?
4. Copilot cites a repository fact that was true last month but the code has since changed. What happens?

<details>
<summary>Answers</summary>

1. **Probably, but do not depend on it.** Repository-level facts are shared with anyone who has access to Copilot Memory in that repository — but only if Memory is enabled and the fact still passes revalidation.
2. **A user-level preference, affecting only you**, across every repository you work in. Your teammates see no change.
3. **`copilot-instructions.md`.** It is a rule you want enforced for everyone, reviewable in a PR, and versioned with the code.
4. **It is discarded.** Facts are stored with citations, and Copilot revalidates the citation against the current branch before using the fact.

</details>

---

## Exercise 4 — Carry state across tools and environments

The same task often moves between your IDE, Copilot CLI, and the cloud agent running in Actions. Each is a different machine with different context.

Decide where each fact must live so it survives the move:

| Fact | Survives IDE → CLI? | Survives → cloud agent? | Where it must live |
| --- | --- | --- | --- |
| "We decided to apply the discount before tax" | ? | ? | ? |
| The current branch name | ? | ? | ? |
| "Run `python3 -m unittest discover -s tests`" | ? | ? | ? |
| Which files are already changed | ? | ? | ? |
| `GITHUB_TOKEN` | ? | ? | ? |

<details>
<summary>Answers</summary>

| Fact | Where it must live |
| --- | --- |
| The discount decision | The issue or PR description. It is a decision, so it needs a durable, reviewable home. |
| Branch name | Git itself — every environment reads it from the checkout. Never pass it as context. |
| Test command | `.github/copilot-instructions.md`. Every tool reads it, so it never has to be remembered. |
| Changed files | `git diff` against the base. Derive it; do not carry it. |
| `GITHUB_TOKEN` | Nowhere you control. Each environment gets its own from its own trust relationship. |

The pattern: **facts that can be derived should be derived, and facts that cannot must be written somewhere every environment reads.** Anything carried only in a session dies at the boundary.

</details>

### The revalidation checklist

Before resuming work in a *different* environment, confirm each of these against the repository rather than against memory:

- The objective and its approved scope
- The current branch, and whether it has moved
- Decisions already made, and where they are recorded
- Which files have already changed
- What validation has already passed
- Open risks and unresolved questions

An agent that resumes without revalidating is not continuing work — it is starting new work that happens to share a branch.

---

## Context drift

Context drift is the failure mode where an agent's assumptions quietly stop matching reality. It is the most common cause of long agent sessions going wrong.

It happens when:

- the agent read a file early, the file changed, and it is still reasoning about the old contents
- earlier turns have scrolled out of the usable context window
- the agent inferred something plausible and never re-checked it

The symptom is characteristic: the agent behaves consistently but incorrectly, and patiently re-explaining does not help, because the flawed assumption is still sitting in context alongside your correction.

What works: start a fresh session, and put the important facts somewhere durable so the new session picks them up automatically. If the same correction is needed twice, it belongs in `copilot-instructions.md`.

---

## Knowledge check

You completed the lab if you can answer without looking:

- How do you tell a new session from a resumed one in a log?
- Which four kinds of state exist, and which of them survives a machine change?
- Where does a rule belong when it must apply to everyone and be reviewable?
- Why is Copilot Memory the wrong home for a team standard?
- What is the fix for context drift, and why is re-explaining not it?
- Which facts should be derived rather than carried between environments
- What must be revalidated before resuming a task on a different machine

---

## Exam preparation

### Paths to memorize

```text
~/.copilot/session-state/<id>/events.jsonl    Session event log
```

### Resuming

- `--resume` — resume a specific session
- `--continue` — continue the most recent session

### How to tell new from resumed in a log

A resumed session shows `resume=true` and a line loading `events.jsonl`. A new session shows neither. Look for the absence.

### Durable state is not chat memory

The exam repeatedly probes this. Chat history is not durable, not shareable, and not auditable. Durable state means PRs, issues, artifacts, and logs. If an answer option proposes passing information between jobs "through the conversation," it is wrong.

### Copilot Memory

| Fact | Value |
| --- | --- |
| Enabled per | **User**, not repository |
| Default on | Individual plans. Business/Enterprise need an admin policy first |
| Two types | Repository-level facts, user-level preferences |
| Who can create repository facts | Users with **write access** only |
| Retention | Deleted after **28 days** unused |
| Validated how | Citations re-checked against the current branch |
| Used by | Copilot cloud agent, Copilot code review, Copilot CLI |
| Code review limitation | Repository facts only — ignores user preferences |

If a question asks where a rule belongs and the rule must apply to everyone and be reviewable, the answer is an instruction file, not Copilot Memory.

### Reading autonomy from a log

Infer the level from the tools that appear:

| Tools observed | Level |
| --- | --- |
| `search`, `read` | Low |
| plus `edit`, `execute` | Medium |
| plus `agent`, MCP servers | High |

---

## Summary

Where agent state actually lives, how to read a session log for session type and autonomy level, which storage mechanism fits each need, and where Copilot Memory sits between session context and repository instructions. Exercise 5 applies this directly: the multi-agent pipeline passes every handoff through workflow artifacts, for exactly the reasons established here.

**Next:** [Lab 04 — Perform Evaluation, Error Analysis, and Tuning](04-evaluation-error-analysis-tuning.md)
