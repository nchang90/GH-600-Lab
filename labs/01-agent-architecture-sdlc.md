# Lab 01: Prepare Agent Architecture and SDLC Processes

## Exam focus

- Integrate agents into the SDLC.
- Define inputs, outputs, and success criteria.
- Separate planning, reasoning, and action.
- Configure observability and control for autonomous agents.

## Scenario

Your team wants to let an agent implement small application changes in this repository. Before the agent can act, the team needs a repeatable task structure and a plan approval process.

## Tasks

### 1. Map agent responsibilities to SDLC stages

Open `templates/agent-task-brief.md` and fill in a task for this change:

> Add support for a 10 percent loyalty discount when a cart total is at least 100.00.

Classify which parts of the work belong to:

- Planning
- Implementation
- Validation
- Review
- Release

### 2. Define inputs, outputs, and success criteria

Add these details to your task brief:

- Input files the agent is allowed to edit
- Files the agent must not edit
- Expected code and test output
- Operational constraints
- Security constraints
- Definition of done

The completed task brief is your planning input; keep it with your Lab 01 work for review.

### 3. Create a structured plan

Create `artifacts/submissions/agent-plan-loyalty-discount.md`.

Use this structure:

```markdown
# Agent Plan: Loyalty Discount

## Intent

## Scope

## Proposed changes

## Files expected to change

## Files explicitly out of scope

## Risks

## Validation plan

## Approval decision
```

The plan should be inspectable before any implementation occurs.

### 4. Define action boundaries

Update the `Approval decision` section with one of:

- `Approved for implementation`
- `Planning only`
- `Blocked pending human review`

Justify the decision based on risk.

## Self-check

You completed the lab if your artifacts answer these questions:

- What should the agent do?
- What should the agent not do?
- What evidence proves the work is complete?
- Which step requires human review?
- Where can a reviewer inspect the agent's plan before code changes?

## Exam notes

For GH-600, expect questions that test whether you can distinguish an assistant-style prompt from a governed agent workflow. The exam is likely to value structured plans, explicit approval gates, traceable artifacts, and clear success criteria over vague instructions like "fix the app."
