# Official GH-600 Domain Map

Source of truth: [Microsoft Learn GH-600 study guide](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/gh-600).

Use this map to align teaching, practice, and assessment with the current official outline. Recheck the official page if its update date or objectives change.

## 1. Prepare agent architecture and SDLC processes (15-20%)

### Integrate agents into the SDLC

- Identify suitable agent steps.
- Identify and mitigate agent anti-patterns.
- Define inputs, outputs, and success criteria.

### Separate planning, reasoning, and action

- Keep planning distinct from execution.
- Produce and validate structured plans.
- Prevent action before required checks and approval.

### Configure observability and control

- Choose autonomy and guardrails appropriate to risk.
- Produce inspectable artifacts in standard development tooling.
- Add human intervention where it materially reduces risk.

Evidence examples: scoped task brief, structured plan, branch, pull request, required checks, review event, rollback plan.

## 2. Implement tool use and environment interaction (20-25%)

### Select and configure tools

- Identify required tools.
- Configure tools and their permissions.

### Configure MCP servers

- Add MCP servers to agents.
- Configure GitHub remote MCP, registries, and allow lists.

### Integrate with development environments

- Evaluate execution context.
- Scope agents to repositories and branches.
- Invoke agents in CI.
- Enable controlled branch and pull-request actions.
- Address environment-specific constraints.

### Operate safely

- Implement error handling, retries, rollback, escalation, traceability, and accountability.

Evidence examples: custom agent frontmatter, narrow tool list, MCP allow list, setup workflow, token permissions, CI invocation, branch scope, error artifact.

## 3. Manage memory, state, and execution (10-15%)

### Implement memory strategies

- Choose short-term, long-term, or external memory.
- Store only task-relevant information.
- Define expiration, pruning, and reset rules.

### Persist state and manage context drift

- Capture progress and decisions durably.
- Resume without repeating work or contradicting decisions.
- Detect and correct drift during extended execution.

### Maintain continuity

- Share state across tools and environments.
- Prevent conflicting or stale context.

Evidence examples: resume artifact, decision log, cited repository fact, expiration rule, branch revalidation, conflict resolution record.

## 4. Perform evaluation, error analysis, and tuning (15-20%)

### Define success and signals

- Specify outcomes and operational constraints.
- Choose qualitative and quantitative signals.
- Align evaluation with development intent.
- Generate signals with automated scanning tools.

### Analyze failures

- Use logs, plans, traces, outputs, and workflow artifacts.
- Classify reasoning, tool, context, and environment causes.

### Tune behavior

- Revise instructions, workflows, constraints, memory, tools, and access based on evidence.

Evidence examples: test and scan output, evaluation report, first failing command, failure taxonomy, measurable instruction change, before-and-after result.

## 5. Orchestrate multi-agent coordination (15-20%)

### Operate multi-agent workflows

- Apply an orchestration pattern.
- Isolate parallel execution.
- Resolve overlap, duplicated work, and contradictory outputs.

### Make behavior observable

- Produce reviewable and auditable artifacts.
- Record decisions, handoffs, and outcomes.
- Perform post-hoc analysis.

### Respond to degraded behavior

- Detect failed, partial, or stalled runs.
- Recover with retry, rollback, replacement, or human intervention.

### Manage lifecycle

- Add, update, replace, and retire agents while preserving continuity and auditability.

Evidence examples: job graph, work ownership, isolated branches or worktrees, handoff contract, completion signal, conflict policy, stalled-agent timeout, consolidated report.

## 6. Implement guardrails and accountability (10-15%)

### Define autonomy levels

- Classify actions by operational, security, and compliance risk.
- Right-size human intervention while preserving delivery speed.

### Implement guardrails and human-in-the-loop workflows

- Identify actions requiring human judgment.
- Block policy violations.
- Enforce least privilege.
- Require explicit authorization for irreversible or compliance-sensitive actions.
- Avoid approvals that do not materially reduce risk.

Evidence examples: autonomy matrix, tool boundary, preventive hook, CODEOWNERS review, ruleset, required check, protected environment, audit event.
