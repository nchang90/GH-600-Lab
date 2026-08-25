# GH-600 Artifact Guide

These practical patterns are derived from the public study workbook and community lab repositories listed under Sources. They illustrate objectives but do not override current Microsoft Learn or GitHub Docs.

## Customization inventory

| Artifact | Purpose | Exam reasoning |
| --- | --- | --- |
| `.github/copilot-instructions.md` | Repository-wide guidance | Guidance is not an enforcement boundary. |
| `.github/instructions/*.instructions.md` | Path-specific guidance | Match the `applyTo` scope to the protected code. |
| `AGENTS.md` | Portable agent-oriented project guidance | Nearest applicable instructions can affect context. |
| `.github/prompts/*.prompt.md` | Reusable task prompt | Prompts define repeatable intent, not permissions. |
| `.github/agents/*.agent.md` | Custom agent profile | Give each agent only the tools its role needs. |
| `.github/skills/<name>/SKILL.md` | Reusable specialized workflow | Description controls when the skill should trigger. |
| `.github/hooks/*.json` | Tool interception and lifecycle hooks | A pre-tool deny can prevent an action; post-tool checks are detective. |
| `.github/workflows/copilot-setup-steps.yml` | Cloud-agent environment setup | Setup must be reproducible and available from the expected branch. |
| `.mcp.json`, `.github/mcp.json`, `.vscode/mcp.json` | MCP server configuration | Limit servers, tools, credentials, and scope. |

## Tool boundaries

| Role | Typical minimum tools | Reason |
| --- | --- | --- |
| Reader or reviewer | `read`, `search` | Inspect without changing state. |
| Implementer | `read`, `search`, `edit`, `execute` | Modify bounded files and validate them. |
| Security scanner | `read`, `search`, `execute` | Run scans without editing findings away. |
| Orchestrator | `read`, `search`, `agent` | Delegate without directly implementing. |

Omitting a tool boundary can grant more capability than intended on some surfaces. Check current platform behavior.

## MCP distinctions

- Custom agent YAML uses `mcp-servers`; JSON configuration uses `mcpServers`.
- A local process normally has `command` and `args`.
- A remote HTTP or SSE server normally has a `url`.
- A URL passed inside a local command's arguments does not make the transport remote.
- Allow only the operations required for the task. Read issue context does not imply permission to merge pull requests.
- Keep credentials out of output and scope tokens to the narrowest resource and action.

## Memory and durable state

Distinguish:

- Session context: useful for the active run, but not sufficient as an audit record.
- Repository instructions: versioned, broadly reusable facts and constraints.
- Durable task artifacts: issues, plans, pull requests, workflow artifacts, logs, and decision records.
- Product memory features: convenient but subject to enablement, expiration, preview status, and revalidation rules.

Before resuming, validate the objective, approved scope, current branch, decisions, changed files, completed validation, open risks, and architecture guidance.

## Evaluation sequence

Diagnose the narrowest likely cause before changing models:

1. Task and success criteria.
2. Instructions.
3. Tool scope and permissions.
4. Setup and environment.
5. Repository or branch state.
6. Memory and session state.
7. Model choice.

This is a diagnostic heuristic, not an official immutable ordering. Use evidence from the failing run.

## Multi-agent patterns

- Use explicit ownership and isolated branches, worktrees, jobs, or file scopes.
- Preserve independent results rather than cancelling all agents when one fails.
- Define artifact names and handoff schemas before execution.
- Consolidation should not silently turn a failed or missing specialist report into success.
- Use timeouts and completion signals to detect stalled agents.
- Define which agent can retry, who resolves contradictions, and when humans intervene.

## Guardrail ladder

| Layer | Effect |
| --- | --- |
| Instructions | Guide desired behavior. |
| Tool and permission bounds | Remove unnecessary capabilities. |
| Preventive hooks | Intercept and deny matched actions. |
| Required checks and scans | Produce evidence and block unsafe promotion. |
| CODEOWNERS and rulesets | Require independent review and enforce merge policy. |
| Protected environments | Require authorization before sensitive deployment. |
| Logs and audit events | Preserve accountability and support investigation. |

Layer controls because no single mechanism covers every path. Hooks can reduce accidents, but protected branches and environments enforce repository and deployment boundaries.

## Community lab cautions

- The community repositories are learning resources, not official exam guides.
- Some exercises require paid Azure resources and organization features.
- Local end-to-end harnesses may not exercise real identity or cloud databases.
- Preview memory behavior and action major versions can change.
- Security scans may be skipped when repository visibility or licensing does not support them.
- A single production environment simplifies real multi-stage promotion.
- Shell-hook pattern matching can be bypassed; use defense in depth.

## Sources

- [Official Microsoft Learn GH-600 study guide](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/gh-600)
- [GH-600 Public Study Guide gist](https://gist.github.com/naim149/a8aa41c7468685b7d984822c38863aae) (personal community resource; may move or disappear)
- [Community lab instructions](https://github.com/sameeraman/gh-600-lab-instructions)
- [Community lab starter](https://github.com/sameeraman/gh-600-lab-starter)
