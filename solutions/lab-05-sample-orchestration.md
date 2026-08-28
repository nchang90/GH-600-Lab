# Lab 05 Sample: Multi-Agent Coordination

Compare this only after you have written your own Step 1 pattern choice and Step 4 conflict rules.

## Step 1 — Pattern

**Parallel isolated with merge review.**

The reviewer, test-runner, and security-scanner examine the same diff. None consumes another's
output, so sequencing them would triple wall-clock time for no benefit. Two of the three cannot
write, which is what makes parallelism safe here — isolation is cheap when nothing contends for
the same files.

A human-in-the-loop coordinator would be correct for a change that deploys or alters governance.
It is the wrong default for a code review, because it adds a gate at every transition without
reducing any risk the pull request itself does not already gate.

## Step 4 — Conflict and degraded-behaviour rules

| Failure | Rule |
| --- | --- |
| Two agents give contradictory recommendations | Report both positions in the consolidated output with the file and line each cites. The consolidator does not pick a winner; a human resolves it in review. |
| An agent stalls and hits the job timeout | `fail-fast: false` keeps the others running. The consolidation job lists the agent under "did not report". Re-run that matrix leg only; do not re-run the whole workflow. |
| An agent produces partial output | Treat partial as absent. Upload whatever exists as evidence, but do not let a truncated report count as a clean pass. |
| Two agents report the same finding | Keep both. Independent agreement from a reviewer and a security-scanner is a stronger signal than either alone, and de-duplicating hides that. |
| Every agent passes but the human disagrees | The disagreement must produce a change: a checklist item, an instruction, or a new agent. An evaluation that changes nothing is an opinion, not a signal. |

## Why the consolidation job names missing agents

A report that silently omits a crashed agent is indistinguishable from one where that agent found
nothing — and those are opposite conclusions. Enumerating non-reporters is what stops the
consolidated output from overstating its own coverage.

## Isolation, mechanically

| Mechanism | What it isolates |
| --- | --- |
| `strategy.matrix` | Each agent gets its own runner, checkout, and filesystem |
| `fail-fast: false` | One agent's failure does not cancel the others' completed work |
| `upload-artifact` | The handoff is a file, not a variable, log line, or shared context |
| `needs: test` | No agent reviews a change whose tests have not run |
| `if: always()` | A partial result still reaches a human |
