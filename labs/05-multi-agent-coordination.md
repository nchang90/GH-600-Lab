# Lab 05 — Multi-Agent Coordination (Domain 5)

**Goal:** run several specialized agents against the same change, keep their work isolated, and consolidate their findings into one reviewable artifact.

**You will create:**

| Step | File | Purpose |
| --- | --- | --- |
| 2 | `.github/workflows/agent-evaluation.yml` | Parallel agent review jobs |
| 3 | `.github/workflows/agent-evaluation.yml` | A consolidation job that depends on them |

Steps 1 and 4 create nothing — they are the pattern choice and the conflict policy that justify the workflow.

**Prerequisite:** [Lab 02](02-tools-mcp-environments.md) (the four agents) and [Lab 04](04-evaluation-error-analysis-tuning.md) (an open pull request to review).

**Time:** About 40 minutes

---

## Step 1 — Choose the pattern

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

## Step 2 — Add the parallel review jobs

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

## Step 3 — Add the consolidation job

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

## Step 4 — Handle conflicts and degraded behaviour

Multi-agent work fails in predictable ways. Decide, in advance, what happens for each:

| Failure | Your rule |
| --- | --- |
| Two agents give contradictory recommendations | ? |
| An agent stalls and hits the job timeout | ? |
| An agent produces partial output | ? |
| Two agents report the same finding | ? |
| Every agent passes but the human disagrees | ? |

Two are worth thinking through carefully.

**Contradiction.** The orchestrator you built in Lab 02 is instructed not to summarize away a disagreement. A consolidator that picks a winner has made a judgement no human reviewed; one that reports both positions has escalated correctly. Silent resolution is the failure.

**The human disagreeing with a unanimous pass.** If your answer is "the agents were wrong," ask what changes as a result — a checklist item, an instruction, a new agent. An evaluation that produces no change to the system is an opinion, not a signal.

**Verify:**

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

**Behavioural test:** push a commit to the Lab 04 branch and open the workflow run. You should see three `Agent review` jobs on separate runners, then one `Consolidate findings` job. Download `consolidated-review` and confirm it names all three agents.

---

## Self-check

You completed the lab if you can explain:

- What isolates the three agents from each other, mechanically
- Why `fail-fast: false` and `if: always()` are both required, and what breaks with only one
- Why the handoff is an artifact rather than a job output or the agent's context
- How a reader of the consolidated report tells "found nothing" from "never ran"
- What happens when two agents disagree

---

## Exam notes

- Multi-agent execution is not "running many agents at once." GH-600 emphasizes isolation, observability, conflict detection, auditability, and safe lifecycle management.
- **Jobs share nothing.** Data moves between them through artifacts or `$GITHUB_OUTPUT`. Any answer proposing shared memory or conversation between jobs is wrong.
- A matrix gives isolation for free; use it when agents must not contend.
- Partial results are still results. Pipelines that discard them on a single failure lose the evidence a reviewer needs most.
- Consolidation is a step someone must own. Findings scattered across seven artifacts have not been reviewed.

### The two flags, and what each one saves

| Flag | Default | What breaks without it |
| --- | --- | --- |
| `fail-fast: false` | `true` | One agent's failure cancels the rest of the matrix, discarding findings that had already completed |
| `if: always()` | skips on failure | Consolidation is skipped exactly when an agent failed — the moment you most need the surviving output |

They solve different halves of the same problem. `fail-fast: false` keeps the other agents running; `if: always()` makes sure someone reads them.

### Absence of findings vs absence of the agent

A consolidated report that silently omits a crashed agent looks identical to one where that agent found nothing — and those are opposite conclusions. Enumerating non-reporters by name is what stops the report overstating its own coverage. This is the single most testable idea in Domain 5.

---

## What you built

A workflow that runs three agents in isolation on the same diff, keeps every agent's output when one fails, and consolidates the results into a single artifact that distinguishes a clean review from a missing one.

**Next:** [Lab 06 — Implement Guardrails and Accountability](06-guardrails-accountability.md)
