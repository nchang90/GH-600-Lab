# GH-600 Capstone: Governed Agent Run

This is the final end-to-end exercise. Treat it like a mini exam simulation.

## Timebox

Set a timer for 90 minutes.

## Scenario

Your organization uses GitHub as the system of record and control plane for AI agent work. A product manager creates this issue:

> Add a 10 percent loyalty discount for carts with a subtotal of at least 100.00. The change must be safe for production and should not alter existing validation behavior.

An autonomous coding agent produces this run summary:

```text
Created branch: agent/loyalty-discount
Changed files:
- app/cart.py
- tests/test_cart.py
- .github/workflows/agent-evaluation.yml
- tools/mcp.allow-list.example.json

Validation:
- New loyalty discount tests passed.
- Existing negative tax-rate test was removed.
- Workflow scope check reported sensitive paths changed.

Agent note:
I changed workflow permissions so Actions can comment on the PR automatically.
I also added pull_requests.merge to the MCP allow list so future runs can complete faster.
```

A second reviewer agent starts but stalls before producing its evaluation report.

Meanwhile, the implementation agent resumes from old memory that says discounts should be stored in global configuration. Current architecture guidance says discounts must be explicit parameters and must not rely on hidden global state.

## Your tasks

Create your answers in `artifacts/capstone-response.md`.

### 1. Structured plan decision

State whether the original implementation should have been:

- Approved for implementation
- Planning only
- Blocked pending human review

Explain why.

### 2. Failure classification

Classify each issue:

| Issue | Classification | Evidence |
| --- | --- | --- |
| Workflow changed outside scope | TBD | TBD |
| MCP allow list expanded to merge PRs | TBD | TBD |
| Existing validation test removed | TBD | TBD |
| Reviewer agent stalled | TBD | TBD |
| Agent resumed with stale global-config memory | TBD | TBD |

Use these classifications:

- Reasoning error
- Tool misuse
- Context issue
- Environment issue
- Governance issue
- Test coverage issue
- Multi-agent coordination issue

### 3. Guardrail decision

For each action, assign an autonomy level:

| Action | Autonomy level | Required control |
| --- | --- | --- |
| Edit `app/cart.py` | TBD | TBD |
| Edit `tests/test_cart.py` | TBD | TBD |
| Edit `.github/workflows/**` | TBD | TBD |
| Edit `tools/**` | TBD | TBD |
| Add MCP `pull_requests.merge` | TBD | TBD |
| Remove existing validation tests | TBD | TBD |
| Deploy or merge | TBD | TBD |

### 4. Required remediation

Write the exact remediation steps before the PR can be approved.

Include:

- Files to revert or rework
- Required reviews
- Required tests and scans
- Required artifacts
- Memory/state correction
- Multi-agent recovery step

### 5. Tuning changes

Write three measurable instruction or workflow changes that would prevent recurrence.

Bad:

```text
Be careful.
```

Good:

```text
Do not edit `.github/**`, `tools/**`, or `policies/**` unless those paths are explicitly listed in the approved plan.
```

### 6. Final approval decision

Choose one:

- Approve
- Request changes
- Block

Explain the decision in five sentences or fewer.

## Scoring guide

Score yourself out of 30.

| Area | Points |
| --- | ---: |
| Correctly separates plan/action/review | 5 |
| Correctly classifies failures | 5 |
| Applies least privilege and MCP controls | 5 |
| Handles memory/context drift | 4 |
| Handles multi-agent stall | 4 |
| Defines evidence and accountability | 4 |
| Gives clear final decision | 3 |

## Passing target

- 24 or higher: exam-ready for scenario reasoning
- 18-23: review missed domains and retry
- Below 18: redo Labs 02, 03, 04, 05, and 06
