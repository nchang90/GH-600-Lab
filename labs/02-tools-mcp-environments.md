# Lab 02: Implement Tool Use and Environment Interaction

## Exam focus

- Select and configure agent tools.
- Configure MCP servers, registries, and allow lists.
- Integrate agents within development environments.
- Operate agents with safe execution paths and robust error handling.

## Scenario

The agent needs access to repository files, GitHub issues, pull requests, and CI results. The team is considering an MCP server to extend the agent's tool access.

## Tasks

### 1. Build a tool inventory

Create `artifacts/tool-inventory.md` with this table:

| Tool | Purpose | Required permission | Risk | Allowed for autonomous use? |
| --- | --- | --- | --- | --- |

Include at least:

- Repository file read
- Branch creation
- Pull request creation
- GitHub Actions log read
- Issue comment write
- Secret read
- Environment approval
- MCP tool for project tracking

### 2. Configure an MCP allow-list design

Review `tools/mcp.allow-list.example.json`.

Create `artifacts/mcp-allow-list-decision.md` and decide:

- Which tools should be allowed
- Which tools should be denied
- Which tools require human approval
- Which repository or organization owns the MCP configuration

### 3. Define execution boundaries

Update `templates/agent-task-brief.md` with boundaries for:

- Repository scope
- Branch scope
- Workflow scope
- Runner environment
- Network access
- Secrets and variables

### 4. Add robust error paths

Create `artifacts/error-handling-runbook.md` covering:

- Retryable failures
- Non-retryable failures
- Rollback triggers
- Escalation path
- Required evidence for post-run review

## Self-check

You completed the lab if you can explain:

- Why tool access should be granted by purpose, not convenience
- How MCP allow lists reduce blast radius
- Why agent access to secrets should be exceptional
- Why branch and workflow scope are separate controls
- What evidence proves a tool action happened

## Exam notes

GH-600 questions in this domain often combine tool choice with execution scope. Watch for answers that grant broad permissions, bypass pull requests, expose secrets, or let agents modify governance files without review.
