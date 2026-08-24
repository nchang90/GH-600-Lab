# Lab 05: Orchestrate Multi-Agent Coordination

## Exam focus

- Operate and manage multi-agent workflows.
- Configure observability for multi-agent behavior.
- Detect and respond to multi-agent failures.
- Manage the agent lifecycle.

## Scenario

Your team wants three agents to work in parallel:

- Planner agent: produces a structured plan.
- Implementation agent: changes code and tests.
- Reviewer agent: evaluates output and posts findings.

## Tasks

### 1. Choose an orchestration pattern

Create `artifacts/submissions/multi-agent-orchestration.md`.

Choose one pattern:

- Sequential handoff
- Manager-worker
- Parallel isolated agents with merge review
- Human-in-the-loop coordinator

Explain why your pattern fits the loyalty discount change.

### 2. Define isolation boundaries

For each agent, specify:

- Branch or workspace
- Allowed files
- Tools
- Required outputs
- Stop conditions

### 3. Produce audit artifacts

Define the artifacts each agent must produce:

| Agent | Required artifact | Reviewer |
| --- | --- | --- |

Include plans, changed files, validation output, handoff notes, and review findings.

### 4. Handle conflicts and degraded behavior

Add a section for:

- Duplicate effort
- Overlapping code changes
- Contradictory recommendations
- Stalled agent
- Partial output
- Rollback and retry

## Self-check

You completed the lab if your orchestration document answers:

- Who coordinates the agents?
- How is work isolated?
- How are conflicts detected?
- Which artifact records handoffs?
- How is a failed or stalled agent recovered?

## Exam notes

Multi-agent execution is not just running many agents at once. GH-600 emphasizes isolation, observability, conflict detection, auditability, and safe lifecycle management.
