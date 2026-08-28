# Lab 05 — Multi-Agent Coordination (Domain 5)

## Introduction

In this lab, you run several specialized agents against the same change, isolate their work, and consolidate their findings into one reviewable artifact.

**Estimated time:** 40 minutes

**Microsoft Learn alignment:** [Multi-Agent systems and orchestration](https://learn.microsoft.com/en-us/training/modules/multi-agent-systems-orchestration/)

## Learning objectives

After completing this lab, you'll be able to:

- Select an appropriate multi-agent coordination pattern.
- Run specialist reviews in parallel and in isolation.
- Preserve partial results when one agent fails.
- Consolidate findings into a single auditable report.
- Distinguish an agent with no findings from an agent that did not run.
- Diagnose conflicts and recover safely from degraded multi-agent execution.

## Prerequisites

- Complete [Lab 02a — Build Custom Agents](02a-custom-agents.md).
- Complete [Lab 04 — Perform Evaluation, Error Analysis, and Tuning](04-evaluation-error-analysis-tuning.md).
- Keep the Lab 04 pull request open for review.

## Lab scenario

The loyalty discount pull request now needs review from testing, security, and general code-review specialists. You must coordinate those reviews without shared mutable state and retain useful evidence even when one specialist fails.

**Lab outputs:**

| Step | File | Purpose |
| --- | --- | --- |
| 2 | `.github/workflows/agent-evaluation.yml` | Parallel agent review jobs |
| 3 | `.github/workflows/agent-evaluation.yml` | A consolidation job that depends on them |

Exercises 1 and 4 create nothing — they are the pattern choice and the conflict policy that justify the workflow.

---

## Exercise 1 — Choose the coordination pattern

Four patterns are available. Pick one for the loyalty discount PR from Lab 04, and be able to defend it:

| Pattern | Coordination | Fits when |
| --- | --- | --- |
| Sequential handoff | Each agent waits for the previous one | Later work depends on earlier output |
| Manager–worker | One agent delegates and collects | Subtasks are independent but need assignment |
| Parallel isolated + merge review | All run at once, one consolidates | Reviews are independent and read-only |
| Human-in-the-loop coordinator | A person gates each transition | The change is high risk |

For a code review the answer is **parallel isolated with merge review**: the reviewer, test-runner, and security-scanner examine the same diff, none of them needs another's output, and running them in sequence would triple the wall-clock time for no benefit.

The property that makes parallelism safe here is that two of the three agents cannot write. Isolation is cheap when nothing contends for the same files.

---

## Exercise 2 — Add the parallel review jobs

**Update this file:** `.github/workflows/agent-evaluation.yml`

Add three jobs that run alongside the existing `test` and `scope-check`:

```yaml
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
        run: |
          git diff "origin/${{ github.base_ref }}"...HEAD > diff.patch
          wc -l diff.patch

      - name: Run ${{ matrix.agent }}
        run: |
          mkdir -p findings
          echo "# Findings from ${{ matrix.agent }}" > "findings/${{ matrix.agent }}.md"
          echo "" >> "findings/${{ matrix.agent }}.md"
          echo "Agent definition: .github/agents/${{ matrix.agent }}.agent.md" \
            >> "findings/${{ matrix.agent }}.md"

      - name: Upload findings
        uses: actions/upload-artifact@v4
        with:
          name: findings-${{ matrix.agent }}
          path: findings/
          retention-days: 7
```

## Exercise 3 — Add the consolidation job

**Update this file:** `.github/workflows/agent-evaluation.yml`

Append one more job:

```yaml
  consolidate:
    name: Consolidate findings
    needs: agent-review
    if: always()
    runs-on: ubuntu-latest
    permissions:
      contents: read

    steps:
      - name: Download all findings
        uses: actions/download-artifact@v4
        with:
          pattern: findings-*
          merge-multiple: true
          path: findings

      - name: Build the consolidated report
        run: |
          {
            echo "# Consolidated agent review"
            echo ""
            for f in findings/*.md; do
              [ -e "$f" ] || continue
              cat "$f"
              echo ""
            done
            echo "## Agents that did not report"
            for a in reviewer test-runner security-scanner; do
              [ -f "findings/$a.md" ] || echo "- $a — no findings artifact"
            done
          } > consolidated-review.md
          cat consolidated-review.md

      - name: Upload consolidated report
        uses: actions/upload-artifact@v4
        with:
          name: consolidated-review
          path: consolidated-review.md
          retention-days: 30
```

### Check your work

```bash
python3 - <<'EOF'
import yaml
d = yaml.safe_load(open(".github/workflows/agent-evaluation.yml"))
jobs = d["jobs"]
assert "agent-review" in jobs, "missing agent-review job"
assert "consolidate" in jobs, "missing consolidate job"
assert jobs["agent-review"]["strategy"]["fail-fast"] is False, "fail-fast must be false"
assert jobs["consolidate"]["needs"] == "agent-review", "consolidate must depend on agent-review"
assert "always()" in str(jobs["consolidate"].get("if", "")), "consolidate needs if: always()"
assert "concurrency" in d, "missing concurrency block"
print("PASS: matrix isolated, failures preserved, consolidation always runs")
EOF
```

Each assertion maps to one thing that breaks without it: cancelled siblings, a skipped consolidation, or two reviews racing on one branch.

---

## Exercise 4 — Handle conflicts and degraded behavior

Multi-agent work fails in predictable ways. Decide, in advance, what happens for each:

| Failure | Your rule |
| --- | --- |
| Two agents give contradictory recommendations | ? |
| An agent stalls and hits the job timeout | ? |
| An agent produces partial output | ? |
| Two agents report the same finding | ? |
| Every agent passes but the human disagrees | ? |

<details>
<summary>Answers</summary>

| Failure | Rule |
| --- | --- |
| Two agents give contradictory recommendations | Report both positions with the file and line each cites. The consolidator does not pick a winner; a human resolves it. |
| An agent stalls and hits the job timeout | `fail-fast: false` keeps the others running; the consolidation job lists it under "did not report". Re-run that matrix leg only. |
| An agent produces partial output | Treat partial as absent. Upload what exists as evidence, but never let a truncated report count as a clean pass. |
| Two agents report the same finding | Keep both. Independent agreement from a reviewer and a security-scanner is stronger than either alone; de-duplicating hides that. |
| Every agent passes but the human disagrees | The disagreement must produce a change — a checklist item, an instruction, or a new agent. |

</details>

Two are worth thinking through carefully.

**Contradiction.** The orchestrator you built in Lab 02a is instructed not to summarize away a disagreement. A consolidator that picks a winner has made a judgement no human reviewed; one that reports both positions has escalated correctly. Silent resolution is the failure.

**The human disagreeing with a unanimous pass.** If your answer is "the agents were wrong," ask what changes as a result — a checklist item, an instruction, a new agent. An evaluation that produces no change to the system is an opinion, not a signal.

### Check your work

```bash
python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/agent-evaluation.yml'))" \
  && echo "PASS: workflow is valid YAML"

grep -q "fail-fast: false" .github/workflows/agent-evaluation.yml \
  && echo "PASS: one agent failing does not cancel the others"

grep -q "if: always()" .github/workflows/agent-evaluation.yml \
  && echo "PASS: consolidation runs even when an agent fails"

grep -q "upload-artifact" .github/workflows/agent-evaluation.yml \
  && echo "PASS: handoff goes through an artifact"
```

### Check the result

Push a commit to the Lab 04 branch and open the workflow run. You should see three `Agent review` jobs on separate runners, then one `Consolidate findings` job. Download `consolidated-review` and confirm it names all three agents.

---

## Knowledge check

You completed the lab if you can explain:

- What isolates the three agents from each other, mechanically
- Why `fail-fast: false` and `if: always()` are both required, and what breaks with only one
- Why the handoff is an artifact rather than a job output or the agent's context
- How a reader of the consolidated report tells "found nothing" from "never ran"
- What happens when two agents disagree

---

## Exam preparation

- Multi-agent execution is not "running many agents at once." GH-600 emphasizes isolation, observability, conflict detection, auditability, and safe lifecycle management.
- **Jobs share nothing.** Data moves between them through artifacts or `$GITHUB_OUTPUT`. Any answer proposing shared memory or conversation between jobs is wrong.
- A matrix gives isolation for free; use it when agents must not contend.
- Partial results are still results. Pipelines that discard them on a single failure lose the evidence a reviewer needs most.
- Consolidation is a step someone must own. Findings scattered across seven artifacts have not been reviewed.

### Isolation has four mechanisms, not one

| Mechanism | Isolates |
| --- | --- |
| `strategy.matrix` | Agents from each other — separate runner, checkout, filesystem |
| `permissions` | What each job's token can reach |
| Branches | Each agent's changes from `main` and from other agents |
| `concurrency` | **Runs of the same workflow from each other** |

The fourth is the one people forget. Without it, pushing twice in quick succession starts a second agent review while the first is still running — two sets of findings land on one pull request, possibly contradicting each other, with no way to tell which reflects the current code.

```yaml
concurrency:
  group: agent-review-${{ github.ref }}
  cancel-in-progress: true
```

`group` keyed on `github.ref` means one run per branch, not one run globally — branches still review in parallel. `cancel-in-progress: true` is right for reviews, where only the latest commit matters; it is wrong for deployments, where cancelling mid-run can leave a partial rollout.

### The two flags, and what each one saves

| Flag | Default | What breaks without it |
| --- | --- | --- |
| `fail-fast: false` | `true` | One agent's failure cancels the rest of the matrix, discarding findings that had already completed |
| `if: always()` | skips on failure | Consolidation is skipped exactly when an agent failed — the moment you most need the surviving output |

They solve different halves of the same problem. `fail-fast: false` keeps the other agents running; `if: always()` makes sure someone reads them.

### Absence of findings vs absence of the agent

A consolidated report that silently omits a crashed agent looks identical to one where that agent found nothing — and those are opposite conclusions. Enumerating non-reporters by name is what stops the report overstating its own coverage. This is the single most testable idea in Domain 5.

---

## Summary

A workflow that runs three agents in isolation on the same diff, keeps every agent's output when one fails, and consolidates the results into a single artifact that distinguishes a clean review from a missing one.

**Next:** [Lab 06 — Implement Guardrails and Accountability](06-guardrails-accountability.md)
