# Lab 02 Sample: Tool Inventory

| Tool | Purpose | Required permission | Risk | Allowed for autonomous use? |
| --- | --- | --- | --- | --- |
| Repository file read | Understand code and tests | Contents read | Low | Yes, with audit |
| Branch creation | Isolate implementation | Contents write or branch permission | Low | Yes, if branch naming policy is followed |
| Pull request creation | Expose changes for review | Pull requests write | Medium | Yes, with PR template |
| GitHub Actions log read | Diagnose failures | Actions read | Low | Yes |
| Issue comment write | Report progress | Issues write | Medium | Approval or scoped automation |
| Secret read | Access sensitive values | Secrets access | Critical | No, unless explicitly approved |
| Environment approval | Deploy or release | Environment approver | Critical | No |
| MCP project tracking read | Read work item context | Tool-specific read | Low | Yes |
| MCP project tracking write | Update external work item | Tool-specific write | Medium | Human approval |

## Allow-list decision

Allowed:

- Repository read
- Issues read
- Pull requests read
- Actions logs read
- Work items read

Requires approval:

- Branch creation
- Pull request creation
- Issue comments
- Work item comments

Denied:

- Secrets read
- Environment approval
- Pull request merge
- Ruleset write
- Admin write

## Error handling

Retry network timeouts, transient API failures, and flaky test runs once. Do not retry policy violations, denied tool access, secret access failures, or CODEOWNER review failures. Escalate with logs, plan, changed files, and tool trace.

