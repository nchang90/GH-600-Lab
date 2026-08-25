# Lab 04 — Perform Evaluation, Error Analysis & Tuning

**Goal:** learn to diagnose why an agent failed and fix the right layer, rather than guessing.

**You will create:**

- `.github/submissions/evaluation-report-loyalty-discount.md`
- `.github/submissions/instruction-tuning-proposal.md`

**Prerequisite:** [Lab 03](03-memory-state-execution.md) complete.

**Time:** About 25 minutes

## Exam focus

- Define success criteria and evaluation signals.
- Analyze agent failures and identify root causes.
- Tune agent behavior based on evaluation results.

## Scenario

An agent attempted to add loyalty discount support but failed CI and modified an unrelated workflow. You need to evaluate the output, classify the failure, and tune future behavior.

---

## Why this lab comes fourth

When someone asks whether an agent is working well, the tempting answer is an impression — the output looked thorough, the reasoning seemed sound. That is not evaluation.

Evaluation means evidence: test results, scan findings, status checks, uploaded artifacts, session logs. Each is independently checkable by someone who was not there.

If the evidence is weak, tuning the model is usually the wrong fix. Work through the cheaper layers first.

---

## The tuning order

When an agent misbehaves, work through the layers in this order.

```text
1. Prompt / task clarity
2. Instructions
3. Tool scope
4. Setup / environment
5. Repository state
6. Memory / session state
7. Model choice          ← LAST
```

The order is not arbitrary. It runs from cheapest and most likely, to most expensive and least likely.

Model choice is last because it is almost never the cause. If the agent could not find your test command, no model solves that — the information was not in its context.

## Tasks

### 1. Define evaluation signals

Open `templates/evaluation-report.md` and create `.github/submissions/evaluation-report-loyalty-discount.md`.

Include signals from:

- Unit tests
- Static checks
- Code review comments
- Changed file list
- Plan adherence
- Security scanning
- Workflow logs

### 2. Analyze the failed run

Read `artifacts/inputs/failed-agent-run.md`.

Classify each issue as one of:

- Reasoning error
- Tool misuse
- Context issue
- Environment issue
- Governance issue
- Test coverage issue

### 3. Propose instruction tuning

Create `.github/submissions/instruction-tuning-proposal.md` with two improvements that would prevent the failure.

Do not add broad instructions like "be careful." Make the instructions measurable. If you apply the proposal to `.github/copilot-instructions.md` in a real repository, treat that as a sensitive-path change and require reviewer attention.

### 4. Tune tool access

Update `.github/submissions/mcp-allow-list-decision.md` or create it if you have not completed Lab 02. Explain which tool access should be changed and why.

## Self-check

You completed the lab if you can explain:

- Which signal detected each failure
- Whether the root cause was reasoning, tools, context, environment, or governance
- Which instruction change was proposed
- Which tool permission changed
- How you would know the next run improved

## Exam notes

Evaluation is broader than "tests passed." GH-600 expects you to use plans, logs, traces, artifacts, workflow output, changed files, scans, and human review as evaluation signals.

## Common pitfalls

**Reaching for a different model first.** It is step 7. Steps 1–6 are cheaper and more often correct.

**Treating instructions as a security control.** They guide behaviour; they do not enforce it.

**Judging agent quality by how good the output reads.** Evaluate on evidence, not prose quality.
