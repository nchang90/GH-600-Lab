# Lab 05 — Multi-Agent Orchestration

**Goal:** learn how to coordinate several specialized agents, isolate their work, and consolidate their output into one reviewable artifact.

**You will create:** `.github/submissions/multi-agent-orchestration.md`

**Prerequisite:** [Lab 04](04-evaluation-error-analysis-tuning.md) complete.

**Time:** About 45 minutes

---

## From one agent to a team

Lab 2 introduced separate agent capabilities. This lab turns that idea into a coordinated workflow: one agent plans, one agent implements, and one agent reviews.

The important part is not the number of agents. It is how their work stays isolated, how their output becomes auditable, and how a stalled or conflicting run gets recovered.

Agent work should never depend on a shared mental model. It should move through explicit artifacts, clear ownership, and reviewable handoffs.

---

## The orchestration principle

Keep the agents separate, make their output visible, and combine their results only after each agent has finished its own job.

```text
plan -> implement -> review -> consolidate
```

Each handoff should be through a file or review artifact that another human or agent can inspect later.

---

## Step 1 - Choose an orchestration pattern

Create `.github/submissions/multi-agent-orchestration.md`.

Choose one pattern:

- Sequential handoff
- Manager-worker
- Parallel isolated agents with merge review
- Human-in-the-loop coordinator

Explain why your pattern fits the loyalty discount change.

### Why this choice matters

Different changes need different coordination. A simple change with clear scope may only need sequential handoff. A higher-risk change may need a human-in-the-loop coordinator so review happens before merge.

The pattern should make isolation obvious and keep the final decision reviewable.

---

## Step 2 - Define isolation boundaries

For each agent, specify:

- Branch or workspace
- Allowed files
- Tools
- Required outputs
- Stop conditions

Write each boundary as a rule, not a suggestion.

### The isolation idea

If two agents can edit the same files at the same time, they can overwrite each other or produce contradictory changes. Isolation prevents that and makes ownership obvious.

---

## Step 3 - Produce audit artifacts

Define the artifacts each agent must produce:

| Agent | Required artifact | Reviewer |
| --- | --- | --- |

Include plans, changed files, validation output, handoff notes, and review findings.

### Why artifacts matter

An audit trail is only useful if someone can open it later and understand what happened. A short, structured artifact is better than a long chat thread.

---

## Step 4 - Handle conflicts and degraded behavior

Add a section for:

- Duplicate effort
- Overlapping code changes
- Contradictory recommendations
- Stalled agent
- Partial output
- Rollback and retry

### Why this matters

Multi-agent work fails in predictable ways. The lab tests whether you can define what happens when two agents disagree, one stalls, or the output is incomplete.

---

## Step 5 - Verify

Run these checks from the repository root:

```bash
test -s .github/submissions/multi-agent-orchestration.md
grep -q "## Isolation boundaries" .github/submissions/multi-agent-orchestration.md
grep -q "## Conflict handling" .github/submissions/multi-agent-orchestration.md
python3 -m unittest discover -s tests
```

If any check fails, fix the artifact before moving on.

---

## Self-check

You completed the lab if your orchestration document answers:

- Who coordinates the agents?
- How is work isolated?
- How are conflicts detected?
- Which artifact records handoffs?
- How is a failed or stalled agent recovered?

---

## Exam notes

Multi-agent execution is not just running many agents at once. GH-600 emphasizes isolation, observability, conflict detection, auditability, and safe lifecycle management.

---

## Common pitfalls

**Treating parallel work as shared work.** Parallel agents still need isolated boundaries.

**Using chat as the handoff.** Handoffs need artifacts, not memory.

**Ignoring stalled output.** Partial work is not complete work.

**Skipping the final consolidation.** The team needs one reviewable result.

---

## What you built

You created one orchestration document that explains how multiple agents work together safely.

**Next:** Move to [Lab 06 — Implement Guardrails and Accountability](06-guardrails-accountability.md).
