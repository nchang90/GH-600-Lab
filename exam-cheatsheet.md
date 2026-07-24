# GH-600 Exam Cheat Sheet

Use this as a fast review before practice questions. The exam is mostly scenario judgment: choose the control that lets agents move quickly while keeping work visible, reversible, and governed.

## Core mental model

> Agents propose, plan, act within scope, produce evidence, and humans approve material risk.

GitHub is the system of record and control plane:

- Issues define intent.
- Plans define scope.
- Branches isolate work.
- Pull requests expose changes.
- Checks and scans evaluate output.
- CODEOWNERS and rulesets enforce review.
- Artifacts, logs, and audit events preserve accountability.

## Domain 1: Architecture and SDLC

| If the scenario says... | Prefer this answer |
| --- | --- |
| Agent starts changing code without a plan | Require structured plan before action |
| Agent task is vague | Define inputs, outputs, constraints, success criteria |
| Agent mixes planning and execution | Separate planning from implementation |
| Stakeholders need visibility | Produce inspectable artifacts in GitHub |
| Delivery is blocked by too many approvals | Right-size approvals by risk |

Avoid answers that let agents bypass pull requests, merge directly, or act on unclear scope.

## Domain 2: Tools, MCP, and environments

| If the scenario says... | Prefer this answer |
| --- | --- |
| Agent needs external capabilities | Add an MCP server with scoped tools |
| MCP server exposes many tools | Use allow lists and least privilege |
| Agent needs CI evidence | Grant read access to workflow logs/artifacts |
| Agent needs secrets | Use explicit approval or deny unless required |
| Agent runs in CI | Scope runner, repository, branch, workflow, and token permissions |

Domain 2 is the highest-weight domain. Know the difference between tool availability, tool permission, execution scope, and workflow permission.

## Domain 3: Memory, state, and execution

| If the scenario says... | Prefer this answer |
| --- | --- |
| Agent resumes old work | Read durable task state and validate current code |
| Agent uses stale assumptions | Detect context drift and re-check citations/artifacts |
| Agent repeats prior steps | Persist decisions and progress as artifacts |
| Multiple agents share context | Share only task-relevant state |
| Memory is no longer valid | Prune, expire, reset, or revalidate memory |

Memory is not the same as state. Durable artifacts are reviewable; memory is supporting context.

## Domain 4: Evaluation and tuning

| If the scenario says... | Prefer this answer |
| --- | --- |
| Tests pass but scope changed | Evaluate changed files and plan adherence |
| Agent failed | Classify root cause using logs, plans, traces, outputs |
| Agent misused a tool | Tune tool permissions or workflow constraints |
| Agent reasoned incorrectly | Tune instructions or task structure |
| Agent regressed security | Use scanning, required checks, and human review |

Evaluation signals include tests, scans, logs, workflow artifacts, review comments, changed files, and plan conformance.

## Domain 5: Multi-agent coordination

| If the scenario says... | Prefer this answer |
| --- | --- |
| Agents work in parallel | Isolate by branch, workspace, files, or role |
| Agents modify same files | Detect conflict and require merge review |
| Outputs contradict | Use a coordinator or human-in-the-loop decision |
| Agent stalls | Escalate, retry, or replace with preserved state |
| New agent joins workflow | Define role, tools, outputs, and lifecycle |

Parallelism without isolation is not orchestration.

## Domain 6: Guardrails and accountability

| If the scenario says... | Prefer this answer |
| --- | --- |
| Agent touches workflows, CODEOWNERS, policies, or MCP config | Require CODEOWNER/security review |
| Agent needs production deployment | Require environment approval |
| Agent needs irreversible action | Require explicit human authorization |
| Agent should move faster | Automate low-risk actions with audit |
| Organization needs proof | Preserve logs, PRs, checks, artifacts, and audit trail |

Do not choose unrestricted autonomy for sensitive files, secrets, production, rulesets, or merges.

## Autonomy levels

| Level | Meaning | Example |
| --- | --- | --- |
| 0 | Blocked | Reading secrets not needed for task |
| 1 | Planning only | Proposing workflow permission changes |
| 2 | Autonomous with audit | Reading repo files or CI logs |
| 3 | Autonomous with required review | Editing application code in PR |
| 4 | Human approval before action | Production deployment or secret access |

