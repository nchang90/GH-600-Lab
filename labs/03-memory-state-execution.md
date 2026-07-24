# Lab 03: Manage Memory, State, and Execution

## Exam focus

- Choose memory strategies.
- Persist agent state and manage context drift.
- Ensure continuity of memory and state across tools and environments.

## Scenario

An agent works on a task for multiple days. During the task, a developer changes the repository architecture. The agent must resume without repeating work or using stale assumptions.

## Tasks

### 1. Create a memory policy

Create `artifacts/memory-policy.md` with sections for:

- Short-term memory
- Long-term repository facts
- User-level preferences
- External memory
- Expiration and pruning
- Reset rules

Use the official concept that repository-level facts should be scoped to the repository and validated against current code before use.

### 2. Persist task state

Create `artifacts/task-state-loyalty-discount.md` with:

```markdown
# Task State: Loyalty Discount

## Current objective

## Decisions already made

## Files inspected

## Files changed

## Validation completed

## Open risks

## Resume instructions
```

### 3. Detect context drift

Read `artifacts/sample-architecture-change.md`.

Add a `Context drift check` section to your task state artifact. Include:

- What changed
- Why the old context may be stale
- What the agent must re-check before continuing

### 4. Share state safely

Write a short handoff note in `artifacts/handoff-note.md` for a second agent that will review the implementation. Include only task-relevant context.

## Self-check

You completed the lab if your artifacts answer:

- What memory should persist?
- What memory should expire?
- How can another agent resume safely?
- How is stale context detected?
- What state should not be shared across unrelated tasks?

## Exam notes

Memory is not a replacement for durable task state. For GH-600, separate temporary conversation context from inspectable artifacts such as plans, task state, decisions, pull requests, logs, and workflow outputs.
