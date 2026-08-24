# Lab 05 Sample: Multi-Agent Orchestration

## Pattern

Use a human-in-the-loop coordinator with sequential handoff:

1. Planner agent writes plan.
2. Human approves scope.
3. Implementation agent changes code and tests.
4. Reviewer agent evaluates plan adherence, tests, changed files, and risks.
5. Human approves or requests changes.

## Isolation boundaries

| Agent | Workspace | Allowed files | Tools | Stop condition |
| --- | --- | --- | --- | --- |
| Planner | Planning branch or artifact-only session | `artifacts/submissions/**` | Repo read | Plan complete or sensitive scope found |
| Implementation | Feature branch | Approved app/test files | Repo read/write, test runner | Tests pass or blocked |
| Reviewer | Read-only review context | None | Repo read, logs read | Report complete |

## Required artifacts

| Agent | Required artifact | Reviewer |
| --- | --- | --- |
| Planner | Structured plan | Human coordinator |
| Implementation | Pull request and task state | Reviewer agent |
| Reviewer | Evaluation report | Human coordinator |

## Conflict handling

- Overlapping changes: stop automatic merge and require coordinator review.
- Contradictory recommendations: record rationale and decision in PR.
- Stalled agent: preserve artifacts, reassign, or retry with same state.
- Partial output: do not merge until required artifacts and checks are complete.

