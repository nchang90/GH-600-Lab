# Lab 05 — Multi-Agent Coordination (Domain 5)

## Introduction

Run specialist agents in isolation, preserve partial results, and consolidate their findings into one reviewable artifact.

**Estimated time:** 30 minutes

**Microsoft Learn alignment:** [Multi-Agent systems and orchestration](https://learn.microsoft.com/en-us/training/modules/multi-agent-systems-orchestration/)

## Learning objectives

After completing this lab, you'll be able to:

- Select a coordination pattern.
- Isolate parallel agents with a matrix and least-privilege permissions.
- Preserve results when an agent fails.
- Consolidate findings and identify missing reports.

## Prerequisites

- Complete [Lab 02a — Build Custom Agents](02a-custom-agents.md).
- Complete [Lab 04 — Evaluation, Error Analysis, and Tuning](04-evaluation-error-analysis-tuning.md).

## Scenario

The loyalty discount pull request needs independent code, test, and security reviews.

**Lab output:** `.github/workflows/agent-evaluation.yml`

## Exercise 1 — Choose the pattern

Use **parallel isolated review with consolidation**. The reviews are independent, so separate matrix jobs are faster and prevent shared mutable state.

## Exercise 2 — Add parallel review jobs

Update `.github/workflows/agent-evaluation.yml`:

```yaml
concurrency:
  group: agent-review-${{ github.ref }}
  cancel-in-progress: true

jobs:
  agent-review:
    name: Agent review
    needs: test
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: read
    strategy:
      fail-fast: false
      matrix:
        agent: [reviewer, test-runner, security-scanner]

    steps:
      - name: Checkout
        uses: actions/checkout@v5
        with:
          fetch-depth: 0

      - name: Collect the diff
        run: git diff "origin/${{ github.base_ref }}"...HEAD > diff.patch

      - name: Run ${{ matrix.agent }}
        run: |
          mkdir -p findings
          echo "# Findings from ${{ matrix.agent }}" > "findings/${{ matrix.agent }}.md"
          echo "Agent definition: .github/agents/${{ matrix.agent }}.agent.md" \
            >> "findings/${{ matrix.agent }}.md"

      - name: Upload findings
        uses: actions/upload-artifact@v4
        with:
          name: findings-${{ matrix.agent }}
          path: findings/
          retention-days: 7
```

Important controls:

- `matrix` gives each agent a separate runner and checkout.
- `fail-fast: false` keeps other agents running after one fails.
- Job permissions remain read-only.
- `concurrency` cancels an outdated review of the same branch.

### Why the concurrency group matters

The group key `agent-review-${{ github.ref }}` is scoped per branch, not per matrix entry. That means:

- Pushing two commits to the same PR branch cancels the older review run and starts a fresh one — you never evaluate stale code.
- Reviews on different branches or PRs run concurrently against each other; they don't share a group and don't cancel one another.
- Inside one run, the matrix jobs (`reviewer`, `test-runner`, `security-scanner`) still run in parallel with each other — `concurrency` controls run-to-run overlap, not job-to-job overlap within a run.

If you widened the group key to something branch-independent (for example, a fixed string), every PR in the repository would queue behind a single concurrency slot. Keep the key scoped to the unit of work you want serialized — usually the ref or PR number.

## Exercise 3 — Consolidate the findings

Add this job:

```yaml
  consolidate:
    name: Consolidate findings
    needs: agent-review
    if: always()
    runs-on: ubuntu-latest
    permissions:
      contents: read

    steps:
      - name: Download findings
        uses: actions/download-artifact@v4
        with:
          pattern: findings-*
          merge-multiple: true
          path: findings

      - name: Build report
        run: |
          {
            echo "# Consolidated agent review"
            for f in findings/*.md; do
              [ -e "$f" ] || continue
              cat "$f"
            done
            echo "## Agents that did not report"
            for a in reviewer test-runner security-scanner; do
              [ -f "findings/$a.md" ] || echo "- $a — no findings artifact"
            done
          } > consolidated-review.md

      - name: Upload report
        uses: actions/upload-artifact@v4
        with:
          name: consolidated-review
          path: consolidated-review.md
          retention-days: 30
```

`if: always()` ensures consolidation runs after a failed matrix job. Naming missing reporters distinguishes “no findings” from “agent did not run.”

## Exercise 4 — Define failure handling

| Situation | Rule |
| --- | --- |
| Agents disagree | Report both positions; a human decides |
| One agent fails | Keep other jobs running and name the missing report |
| Output is partial | Preserve it as evidence, but do not count it as a pass |
| Findings overlap | Keep both as independent confirmation |
| Human disagrees | Update a checklist, instruction, or agent |

## Check your work

```bash
grep -q "fail-fast: false" .github/workflows/agent-evaluation.yml
grep -q "if: always()" .github/workflows/agent-evaluation.yml
grep -q "upload-artifact" .github/workflows/agent-evaluation.yml
grep -q "concurrency:" .github/workflows/agent-evaluation.yml
```

Push a commit and inspect the workflow. It should run three review jobs followed by one consolidation job.

## Check your understanding

- Jobs do not share memory; use outputs or artifacts.
- `fail-fast: false` preserves sibling jobs.
- `if: always()` preserves consolidation.
- A missing report is not a clean review.
- Humans resolve contradictions.

## Summary

You created an isolated parallel review workflow that retains failures and produces one auditable report.

**Next:** [Lab 06 — Guardrails & Accountability](06-guardrails-accountability.md)
