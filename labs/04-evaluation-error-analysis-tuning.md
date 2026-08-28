# Lab 04 — Perform Evaluation, Error Analysis, and Tuning (Domain 4)

## Introduction

In this lab, you diagnose why an agent run failed, fix the correct layer, and produce evidence that a reviewer can check independently.

**Estimated time:** 30 minutes

**Microsoft Learn alignment:** [Memory, State, and Evaluation](https://learn.microsoft.com/en-us/training/modules/memory-state-evaluation/)

## Learning objectives

After completing this lab, you'll be able to:

- Evaluate an agent run using multiple evidence signals.
- Classify and prioritize agent failures.
- Implement and test a corrective code change.
- Tune repository instructions with a measurable rule.
- Use a pull request as an independently reviewable evaluation report.

## Prerequisites

- Complete [Lab 03 — Memory, State & Execution](03-memory-state-execution.md).
- Use a fork where you can create branches and pull requests.

## Lab scenario

An agent attempted to add loyalty discount support to the cart. Its code appeared successful locally but failed in CI and crossed repository boundaries. You must analyze the evidence, correct the implementation, tune the right control layer, and report the result.

**Lab outputs:**

| Step | Artifact | Purpose |
| --- | --- | --- |
| 3 | `app/cart.py` and `tests/test_cart.py` | The change, done correctly |
| 4 | `.github/copilot-instructions.md` | One measurable instruction that prevents the failure |
| 5 | A pull request on `agent/loyalty-discount` | The evaluation report itself |

Exercises 1 and 2 create nothing — they are the failure analysis the rest of the lab acts on.

---

## The tuning order

When an agent misbehaves, work through the layers in this order:

```text
1. Prompt / task clarity
2. Instructions
3. Tool scope
4. Setup / environment
5. Repository state
6. Memory / session state
7. Model choice          <- LAST
```

The order runs from cheapest and most likely, to most expensive and least likely. Model choice is last because it is almost never the cause. If the agent could not find your test command, no model solves that — the information was not in its context.

---

## Exercise 1 — Analyze the failed run

An agent was asked to add loyalty discount support to the cart. It produced code that passed on its own machine and failed in CI. Here is the record — read it as evidence, not as narrative.

**Task given to the agent**

> Add loyalty discount support to the cart. A customer with a loyalty tier should get a
> percentage off the subtotal before tax is applied. Add tests.

Branch `agent/loyalty-discount`, medium autonomy: `read`, `search`, `edit`, `execute`.

**Session log (abridged)**

```text
2026-08-26T10:02:11Z session.id=run-88 cwd=/workspace/GH-600Lab
2026-08-26T10:02:19Z tool=search args="discount"
2026-08-26T10:02:21Z tool=read args="app/cart.py"
2026-08-26T10:02:44Z tool=edit args="app/cart.py"
2026-08-26T10:03:02Z tool=execute args="pytest"
2026-08-26T10:03:03Z stderr="command not found: pytest"
2026-08-26T10:03:29Z tool=execute args="python3 -m pytest"
2026-08-26T10:03:30Z stderr="No module named pytest"
2026-08-26T10:04:07Z tool=edit args="requirements.txt"
2026-08-26T10:04:20Z tool=execute args="pip install pytest"
2026-08-26T10:04:55Z tool=edit args="tests/test_cart.py"
2026-08-26T10:05:31Z tool=execute args="python3 -m pytest tests/"
2026-08-26T10:05:33Z stdout="2 passed"
2026-08-26T10:06:10Z tool=edit args=".github/workflows/agent-evaluation.yml"
2026-08-26T10:06:44Z tool=execute args="git push origin agent/loyalty-discount"
```

**What the diff contained**

```text
 app/cart.py                            | 14 ++++++++++----
 tests/test_cart.py                     |  9 +++++----
 requirements.txt                       |  1 +
 .github/workflows/agent-evaluation.yml |  4 ++--
```

```python
def calculate_total(items, tax_rate=0.0, loyalty_discount=0.0):
    subtotal = calculate_subtotal(items)
    discounted = subtotal * (1 - loyalty_discount)
    return round(discounted * (1 + tax_rate), 2)
```

The `tax_rate < 0` guard that opened the function is gone. Four tests were rewritten in `pytest` style, and `test_rejects_negative_tax_rate` was deleted with the message "remove test for behaviour no longer present". The workflow's `python -m unittest discover -s tests` became `python -m pytest tests/`.

**CI result**

```text
Unit tests ................ FAIL   ModuleNotFoundError: No module named 'pytest'
Sensitive file scope check  FAIL   .github/ changed — CODEOWNER review required
```

Classify each finding. Use exactly one category per finding:

| Category | Means |
| --- | --- |
| Reasoning error | The agent's logic was wrong |
| Tool misuse | It used a capability it should not have, or used one badly |
| Context issue | It lacked information that exists somewhere in the repo |
| Environment issue | Its environment differed from CI's |
| Governance issue | It changed something that required review |
| Test coverage issue | It removed or failed to add necessary tests |

**Findings to classify**

1. It ran `pytest`, which is not installed and is not this repository's test runner.
2. It edited `requirements.txt` and ran `pip install` to make its chosen runner work.
3. It deleted `test_rejects_negative_tax_rate`.
4. It removed the `tax_rate < 0` guard from `calculate_total`.
5. It edited `.github/workflows/agent-evaluation.yml` to change the CI test command.
6. The suite passed locally and failed in CI.

<details>
<summary>Answers</summary>

1. **Context issue.** The correct command is in `.github/copilot-instructions.md` and in the workflow. The agent had access to both and used neither. Note this is *not* a reasoning error — the information existed; the agent did not retrieve it.
2. **Tool misuse.** Changing dependency manifests to accommodate a preference is scope expansion. The task was a discount calculation.
3. **Test coverage issue.** The commit message — "remove test for behaviour no longer present" — is circular: the behaviour is absent because finding 4 removed it.
4. **Reasoning error.** Refactoring the function silently dropped validation. The agent did not notice because it had already deleted the test that would have caught it.
5. **Governance issue.** An agent editing the workflow that grades it can grant itself a passing result. This is the most serious finding, and the only one where severity comes from *who* made the change rather than what it did.
6. **Environment issue.** The runner installs no dependencies. Passing locally is not evidence.

</details>

## Exercise 2 — Rank findings by severity

Order the six findings by severity, then answer:

- Which finding did the test suite detect? Which did it miss entirely?
- Which finding would still be invisible if CI had passed?
- Which single control, if it had existed, would have stopped the most findings?

<details>
<summary>Discussion</summary>

CI caught findings 1 and 5 — one by failing, one by the scope check. It could not catch 3 and 4, because the agent removed the evidence in the same commit. Finding 4 is the actual defect a customer would hit; it is also the one with the weakest detection story.

The highest-leverage control is a path restriction preventing agents from editing `.github/**`. It stops finding 5 outright, and it makes finding 1 self-correcting, because an agent that cannot change the CI command has to satisfy the existing one.

</details>

---

## Exercise 3 — Implement the change correctly

**Update these files:** `app/cart.py` and `tests/test_cart.py`

Make the change the agent should have made.

```bash
git checkout -b agent/loyalty-discount
```

Add loyalty discount support to `app/cart.py`, keeping every existing guard, and add tests to `tests/test_cart.py` covering:

- a discount applied before tax
- a zero discount leaving the total unchanged
- a negative discount rejected with `ValueError`
- a discount above `1.0` rejected with `ValueError`

### Check your work

```bash
python3 -m unittest discover -s tests
git diff --name-only main...HEAD
```

The test run must pass, and the changed-file list must contain only `app/cart.py` and `tests/test_cart.py`. If `.github/` or `infra/` appears, you have reproduced finding 5.

---

## Exercise 4 — Tune the right layer

**Update this file:** `.github/copilot-instructions.md`

The tuning order puts instructions second, after task clarity. Add **one** rule that would have prevented finding 1 or finding 5.

Make it measurable. "Be careful with workflows" is not a rule — a reviewer cannot tell whether it was followed. "Do not edit `.github/**` unless the task brief lists those paths in scope" is checkable against a diff.

> **This is a sensitive-path change.** `.github/` is on your own sensitive list, so this edit needs reviewer attention — including when you are the one making it. Lab 06 builds the control that enforces this rather than requesting it.

### Check your work

```bash
test -s .github/copilot-instructions.md
git diff main...HEAD -- .github/copilot-instructions.md
```

Read your own diff and ask whether a reviewer could tell, from a future PR's changed-file list alone, whether the rule was followed. If not, rewrite it.

---

## Exercise 5 — Open the pull request

Push the branch and open a PR. **The PR body is your evaluation report** — not a file in the repository.

This is the point of the lab. Lab 03 established that durable, auditable state lives in pull requests, artifacts, and logs. An evaluation report committed as a markdown file is a document about evidence; a PR body sits attached to the diff, the test run, and the reviewer's approval, which *are* the evidence.

Write the body with this structure:

````markdown
# Agent Evaluation Report

## Task

## Expected outcome

## Actual outcome

## Evaluation signals

| Signal | Result | Evidence |
| --- | --- | --- |
| Unit tests | | |
| Static checks | | |
| Changed file scope | | |
| Plan adherence | | |
| Security scan | | |
| Workflow logs | | |
| Human review | | |

## Failure classification

| Finding | Classification | Root cause | Corrective action |
| --- | --- | --- | --- |

## Tuning actions

## Final decision
````

```bash
gh pr create --title "Add loyalty discount support" --body-file evaluation.md
```

Every **Evidence** cell takes something a reviewer can click or run — a workflow run URL, a command and its output, a file path. A cell reading "verified" is not evidence.

Two signals have no automated source in this repository: `Static checks` and `Security scan`. Write `not configured` rather than inventing a result, and note what you would add. **A signal you did not collect is not a signal that passed** — an evaluation that quietly omits its gaps is the same failure as a consolidated report that hides a crashed agent.

### Check your work

```bash
gh pr view --json statusCheckRollup --jq '.statusCheckRollup[] | "\(.name): \(.conclusion)"'
```

Both `Unit tests` and `Sensitive file scope check` should report `SUCCESS`.

---

## Knowledge check

You completed the lab if you can explain:

- Which signal detected each of the six findings, and which findings no signal caught
- Why a passing test suite was not evidence in the failed run
- Which layer of the tuning order you changed, and why not a higher-numbered one
- Why the evaluation report belongs in the pull request rather than in a committed file
- How you would know the next run improved

---

## Exam preparation

- Evaluation is broader than "tests passed." GH-600 expects plans, logs, traces, artifacts, workflow output, changed files, scans, and human review as evaluation signals.
- **Model choice is step 7 of 7.** If an answer option proposes switching models before checking instructions, tool scope, or environment, it is wrong.
- Instructions guide behaviour; they do not enforce it. A question asking how to *prevent* an edit is asking about tool scope, hooks, or branch protection — not about a better-worded instruction.
- Evidence must be independently checkable. "The agent reported success" is not a signal.

---

## Summary

A classified failure analysis, a correct implementation on a branch, one measurable instruction change, and a pull request whose body is the evaluation report — with every signal backed by something a reviewer can independently check.

**Next:** [Lab 05 — Multi-Agent Coordination](05-multi-agent-coordination.md)
