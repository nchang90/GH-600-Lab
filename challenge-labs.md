# GH-600 Challenge Labs

These are exam-style challenge drills. Each challenge gives you a risky agent output. Your job is to classify the issue, choose the right GitHub control, and write the next action.

Use this response format for each challenge:

```markdown
## Challenge X response

### Failure classification

### Risk level

### Correct control

### Human-in-the-loop decision

### Evidence required

### Tuning action
```

## Challenge 1: The unapproved workflow edit

An agent was approved to add a cart discount in `app/cart.py` and `tests/test_cart.py`.

The pull request includes these changed files:

```text
app/cart.py
tests/test_cart.py
.github/workflows/agent-evaluation.yml
```

The workflow change removes explicit read-only permissions:

```yaml
permissions: {}
```

and relies on the repository default token permissions.

### Your task

Decide whether to approve, request changes, or block the pull request. Explain which control should catch this and what instruction or rule should be tuned.

### Expected reasoning

- Sensitive path changed outside plan.
- Workflow permission behavior changed.
- Required CODEOWNER/security review is needed.
- Tests alone are not enough.

## Challenge 2: The overpowered MCP server

A team configures a remote MCP server for an agent. The server exposes these tools:

```text
issues.read
issues.comment.write
pull_requests.create
pull_requests.merge
secrets.read
rulesets.write
actions.logs.read
```

The agent's task is to diagnose a failing CI run and propose a fix.

### Your task

Create the minimum safe allow list. Identify which tools are allowed, which require approval, and which are denied.

### Expected reasoning

- CI diagnosis needs read access to repository context and Actions logs.
- Merge, secrets, and ruleset write are not needed.
- PR creation may be allowed only if the task includes implementation.
- Comment write may require approval or constrained automation.

## Challenge 3: The stale memory problem

An agent resumes a week-old task. Its memory says:

> Discount rules are stored in global config and loaded at import time.

Current architecture guidance says:

> Discount rules must be explicit parameters to pricing functions. Hidden global pricing config is not allowed.

The agent starts implementing global configuration.

### Your task

Explain how to stop context drift and safely resume the task.

### Expected reasoning

- Current repository evidence beats stale memory.
- Durable state and architecture artifacts must be re-read.
- The agent should update task state with a context drift finding.
- Memory should be pruned, reset, or corrected.

## Challenge 4: The partial multi-agent run

Three agents are assigned:

- Planner agent creates the plan.
- Coder agent implements the change.
- Reviewer agent evaluates the output.

The planner completes. The coder completes. The reviewer stalls and produces no report. All tests pass.

### Your task

Decide whether the pull request can be approved. Define the recovery action.

### Expected reasoning

- Required review artifact is missing.
- Passing tests do not replace evaluation.
- Preserve planner/coder artifacts.
- Retry, reassign, or complete reviewer task before approval.

## Challenge 5: The hidden regression

An agent adds the requested feature and all new tests pass. Existing negative-input tests were deleted because they were "not related to the requested feature."

### Your task

Classify the failure and tune the agent instructions.

### Expected reasoning

- This is a reasoning error and test coverage/governance issue.
- Existing validation must not be removed unless explicitly in scope.
- Evaluation must inspect deleted tests, not just test pass/fail.

## Challenge 6: The production shortcut

An agent opens a PR and comments:

> I can deploy this directly to production after checks finish to save time.

The change is a small bug fix.

### Your task

Assign an autonomy level and choose the correct guardrail.

### Expected reasoning

- Production deployment is high or critical risk.
- Require environment approval and human authorization.
- Low code risk does not remove deployment risk.

## Challenge 7: The vague task brief

An issue says:

> Improve agent safety.

The agent proposes changes to CODEOWNERS, workflows, MCP config, and Copilot instructions.

### Your task

Explain why this should remain planning-only until clarified.

### Expected reasoning

- Scope is too broad.
- Multiple sensitive paths are involved.
- Inputs, outputs, and success criteria are missing.
- Human approval is required before action.

## Challenge 8: The audit gap

An agent claims it used an MCP project-tracker tool to update a work item, but no artifact, log, or comment records the action.

### Your task

Decide whether the run is accountable enough and what evidence should be required.

### Expected reasoning

- Tool actions must be traceable.
- Require logs, workflow artifacts, PR comments, or audit records.
- Update the runbook to require evidence for external tool actions.

