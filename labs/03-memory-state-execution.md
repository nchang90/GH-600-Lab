# Lab 03 — Memory, State & Execution (Domain 3)

**Goal:** understand where agent state actually lives, how a session is resumed, and which storage mechanism fits each kind of state.

**You will create:** nothing — this lab is analysis and judgement.

**Prerequisite:** [Lab 02](02-tools-mcp-environments.md) complete.

**Time:** ~30 minutes

---

## Why an exercise with no files

This exercise is about the mental model, not a repo change. The exam checks whether you can tell session context, durable artifacts, repository instructions, and Copilot Memory apart.

The point is not to ask for more memory. It is to change what goes into the bundle.

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

## Task 1 — Read a session log

Here is a Copilot CLI log. Work out what it tells you before reading on.

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
2. Which IDE is connected?
3. Which MCP servers are loaded?
4. What autonomy level does this agent have?
5. What tool sequence did it use?

Answers

1. **New session.** There is no `resume=true` and no line loading `events.jsonl`.
2. **Visual Studio Code.**
3. **`github` and `playwright`.**
4. **Medium.** It used `read`, `search`, `edit`, and `execute`.
5. **search → read → edit → execute.**

### What the sequence means

Good agent work finds context, reads it, changes it, and verifies it.

---

## Task 2 — Match each scenario to the right storage

Write the matching letter (A-E) next to each number.

| # | Scenario |
| --- | --- |
| 1 | Continue the same agent session later |
| 2 | Share a plan between workflow jobs |
| 3 | Preserve a review decision for audit |
| 4 | Store a long-term repository convention |
| 5 | Track what an agent did and why |

**Options:** A) Session ID / session-state · B) Workflow artifact or job output · C) PR comment / review · D) Instructions or repository memory · E) Session logs / PR timeline

Answers

1. **A — Session ID / session-state.**
2. **B — Workflow artifact or job output.**
3. **C — PR comment / review.**
4. **D — Instructions or repository memory.**
5. **E — Session logs / PR timeline.**

### Decision vs event

A review captures a decision. Logs and timelines capture events. Audits need both.

---

## Task 3 — Inspect your own Copilot Memory

This one is hands-on, and it takes two minutes.
1. Open **[github.com/settings/copilot/memory](https://github.com/settings/copilot/memory)**.
2. Check whether Memory is enabled.
3. Read the listed preferences and their citations.
4. Delete anything stale or wrong.

**Questions**

1. A teammate's session learned that this repo deploys through `ci.yml`. Will your session know that?
2. You tell Copilot "always use British spelling in comments." Where does that land?
3. A repository fact was true last month, but the code changed. What happens?
4. Your team has a rule that every new endpoint needs a test. Copilot Memory or `copilot-instructions.md`?

Answers

1. **Probably, but do not depend on it.** Repository facts are shared, but only if Memory is enabled and the fact still passes revalidation.
2. **User-level preference; only you see it.**
3. **It is discarded after revalidation fails.**
4. **`copilot-instructions.md`.** It is a team rule that should apply to everyone and be reviewable in Git.

---

## Context drift

Context drift happens when the agent's assumptions stop matching reality.

What works:

- start a fresh session
- store important facts durably
- update `copilot-instructions.md` if the correction is recurring

---

## Exam notes

- Session context is temporary.
- Durable artifacts are the real record.
- Repository instructions are for rules that must apply to everyone.
- Copilot Memory is shared, cited, revalidated, and expires after 28 days unused.
- If a rule must hold for the whole team, put it in an instruction file.

---

## Common pitfalls

- Assuming the agent remembers earlier corrections
- Passing data between workflow jobs without an artifact
- Treating a plan as proof
- Relying on Copilot Memory for team standards

---

## What you learned

Where agent state lives, how to read a session log, which storage fits each need, and where Copilot Memory sits between session context and repository instructions.

**Next:** [Lab 04 — Perform Evaluation, Error Analysis, and Tuning](04-evaluation-error-analysis-tuning.md)
