# Lab 04 — Perform Evaluation, Error Analysis, and Tuning (Domain 4)

## Introduction

Analyze a failed agent run, correct the implementation, tune the right control, and record independently verifiable evidence.

**Estimated time:** 30 minutes

**Microsoft Learn alignment:** [Memory, State, and Evaluation](https://learn.microsoft.com/en-us/training/modules/memory-state-evaluation/)

## Learning objectives

After completing this lab, you'll be able to:

- Classify agent failures using evidence.
- Implement and test a corrective change.
- Tune a measurable repository instruction.
- Use a pull request as an evaluation report.

## Prerequisites

- Complete [Lab 03 — Memory, State & Execution](03-memory-state-execution.md).
- Use a fork where you can create branches and pull requests.

## Lab scenario

An agent added loyalty discounts, changed the repository's test runner, removed validation, and edited its evaluation workflow. You must diagnose and correct the run.

**Lab outputs:**

| Exercise | Artifact |
| --- | --- |
| 3 | `app/cart.py` and `tests/test_cart.py` |
| 4 | `.github/copilot-instructions.md` |
| 5 | Pull request on `agent/loyalty-discount` |

## Tuning order

Check these layers before changing the model:

1. Task clarity
2. Instructions
3. Tool scope
4. Environment
5. Repository state
6. Memory or session state
7. Model choice

## Exercise 1 — Analyze the failed run

The agent had `read`, `search`, `edit`, and `execute`. Its log showed:

```text
tool=read app/cart.py
tool=edit app/cart.py
tool=execute pytest                       -> command not found
tool=edit requirements.txt
tool=execute pip install pytest
tool=edit tests/test_cart.py
tool=execute python3 -m pytest tests/     -> 2 passed
tool=edit .github/workflows/agent-evaluation.yml
```

The diff:

- Added `loyalty_discount` to `calculate_total`.
- Removed the negative `tax_rate` guard.
- Deleted `test_rejects_negative_tax_rate`.
- Added pytest as a dependency.
- Replaced the CI unittest command with pytest.

CI reported:

```text
Unit tests ................ FAIL   ModuleNotFoundError: No module named 'pytest'
Sensitive file scope check  FAIL   .github/ changed — CODEOWNER review required
```

Classify each finding:

| Finding | Classification |
| --- | --- |
| Used the wrong test command | ? |
| Changed dependencies to support that command | ? |
| Deleted an existing validation test | ? |
| Removed the negative-tax guard | ? |
| Edited the evaluation workflow | ? |
| Passed locally but failed in CI | ? |

<details>
<summary>Answers</summary>

| Finding | Classification |
| --- | --- |
| Used the wrong test command | Context issue |
| Changed dependencies to support that command | Tool misuse |
| Deleted an existing validation test | Test coverage issue |
| Removed the negative-tax guard | Reasoning error |
| Edited the evaluation workflow | Governance issue |
| Passed locally but failed in CI | Environment issue |

</details>

## Exercise 2 — Prioritize the findings

Answer:

1. Which finding could let the agent weaken its own evaluation?
2. Which customer-facing defect was hidden by deleting its test?
3. Which control would prevent the highest-risk scope change?

<details>
<summary>Answers</summary>

1. Editing `.github/workflows/agent-evaluation.yml`.
2. Removing the negative `tax_rate` guard.
3. A tool or path restriction preventing agent edits to `.github/**`.

</details>

## Exercise 3 — Implement the change correctly

Create the branch:

```bash
git checkout -b agent/loyalty-discount
```

Update `app/cart.py` and `tests/test_cart.py`:

- Apply the loyalty discount before tax.
- Preserve all existing validation.
- Test a valid discount, zero discount, negative discount, and discount above `1.0`.
- Reject invalid discounts with `ValueError`.

### Check your work

```bash
python3 -m unittest discover -s tests
git diff --name-only main...HEAD
```

Tests must pass. At this point, only `app/cart.py` and `tests/test_cart.py` should appear.

## Exercise 4 — Tune the instructions

Add one measurable rule to `.github/copilot-instructions.md`, such as:

> Do not edit `.github/**` unless the task brief explicitly lists those paths in scope.

Instructions guide behavior; tool restrictions, hooks, and branch protection enforce it.

### Check your work

```bash
test -s .github/copilot-instructions.md
git diff main...HEAD -- .github/copilot-instructions.md
```

## Exercise 5 — Open the evaluation pull request

Push the branch and use the PR body as the evaluation report:

```markdown
# Agent Evaluation Report

## Task

## Expected and actual outcome

## Evaluation signals

| Signal | Result | Evidence |
| --- | --- | --- |
| Unit tests | | |
| Changed file scope | | |
| Plan adherence | | |
| Security scan | | |
| Workflow logs | | |
| Human review | | |

## Failure classification

| Finding | Classification | Corrective action |
| --- | --- | --- |

## Tuning action

## Final decision
```

Create and check the PR:

```bash
gh pr create --title "Add loyalty discount support" --body-file evaluation.md
gh pr view --json statusCheckRollup --jq '.statusCheckRollup[] | "\(.name): \(.conclusion)"'
```

Use links, commands, outputs, and file paths as evidence. Write `not configured` for signals you did not collect—never report an uncollected signal as passed.

## Check your understanding

- Evaluation includes tests, scope, logs, artifacts, scans, and human review.
- A local pass is not evidence that CI will pass.
- Model choice comes after task, instructions, tools, environment, repository state, and memory.
- Evidence must be independently checkable.

## Summary

You classified a failed run, corrected the code and tests, added a measurable instruction, and recorded the evaluation in a pull request.

**Next:** [Lab 05 — Multi-Agent Coordination](05-multi-agent-coordination.md)
