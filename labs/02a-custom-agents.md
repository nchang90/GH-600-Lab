# Lab 02a — Build Custom Agents (Domain 2)

## Introduction

In this lab, you build four custom agents whose capabilities differ on purpose. Each agent receives only the tools required for its role, so capability boundaries are enforced by configuration rather than prompt wording.

**Estimated time:** 25 minutes

**Microsoft Learn alignment:** [Tooling, MCP, and Agent Execution Environments](https://learn.microsoft.com/en-us/training/modules/agent-tooling-mcp-execution-environments/) and the custom-agent exercise in [Multi-Agent systems and orchestration](https://learn.microsoft.com/en-us/training/modules/multi-agent-systems-orchestration/)

## Learning objectives

After completing this lab, you'll be able to:

- Define custom agents with YAML frontmatter and focused instructions.
- Apply least privilege to agent tool lists.
- Separate review, test execution, security analysis, and orchestration roles.
- Explain how agent descriptions support delegation.

## Prerequisites

- Complete [Lab 01 — Prepare Agent Architecture](01-agent-architecture-sdlc.md).

## Lab scenario

Your repository needs specialized agents for review, testing, security scanning, and coordination. You must ensure that each agent can perform its job without receiving unrelated write or execution capabilities.

**Lab outputs:**

| Step | File | Tools |
| --- | --- | --- |
| 1 | `.github/agents/reviewer.agent.md` | `read`, `search` |
| 2 | `.github/agents/test-runner.agent.md` | `read`, `search`, `edit`, `execute` |
| 3 | `.github/agents/security-scanner.agent.md` | `read`, `search`, `execute` |
| 4 | `.github/agents/orchestrator.agent.md` | `read`, `search`, `agent` |

## Agent file format

Every file in `.github/agents/` has YAML frontmatter — `name`, `description`, `tools` — and a markdown body that becomes the agent's system prompt. Exercise 1 shows a complete one.

**`description` is the field that matters most.** A coordinating agent reads it when deciding whether to delegate, so write it as *when you would use this*, not *what this is*.

### The available tools

| Tool | Grants |
| --- | --- |
| `read` | Reading file contents |
| `search` | Searching across the codebase |
| `edit` | Creating and modifying files |
| `execute` | Running shell commands |
| `agent` | Invoking other agents |
| `web` | Fetching external web content |

---

## Exercise 1 — Create the reviewer agent

**Create this file:** `.github/agents/reviewer.agent.md`

````markdown
---
name: reviewer
description: "Reviews changes to the cart application for defects, security risks, missing tests, and violations of repository conventions."
tools:
  - read
  - search
---

You are a read-only code reviewer for this repository.

## Review checklist

1. Identify correctness and security defects.
2. Check input validation and error handling in `app/`.
3. Confirm monetary calculations round only at the boundary, not on every operation.
4. Identify missing tests for changed behavior in `tests/`.
5. Check whether the change touches `.github/`, `tools/`, or `infra/`.
6. Check for committed secrets or credentials.

## Constraints

- Do not edit files.
- Do not execute commands.
- Report only actionable findings supported by code evidence.
- List the most severe findings first.

````


**Behavioural test:** select `reviewer` in the agent picker and ask it to fix a bug in `app/cart.py`. It should report the bug and decline to change the file. That refusal is the feature.

---

## Exercise 2 — Create the test-runner agent

**Create this file:** `.github/agents/test-runner.agent.md`

````markdown
---
name: test-runner
description: "Runs the cart application test suite, diagnoses failures, and repairs broken tests when the fault is in test code."
tools:
  - read
  - search
  - edit
  - execute
---

You are the test execution and analysis agent for this repository.

## Responsibilities

1. Run the test suite for the changed code.
2. Diagnose failures using test output and source evidence.
3. Repair broken or missing tests when the fix is clearly in test code.
4. Report results and remaining risks.

## Commands

- Full suite: `python3 -m unittest discover -s tests`
- Single module: `python3 -m unittest tests.test_cart`

Run from the repository root. The tests import `app.cart`, which resolves only from the root.

## Constraints

- Do not weaken or delete assertions to make a test pass.
- Do not change `app/` to satisfy a failing test without first stating the cause.
- Report the exact command and its result.
- Do not edit `.github/`, `tools/`, or `infra/`.

````

**Behavioural test:** break an assertion in `tests/test_cart.py`, then ask `test-runner` to investigate. It should identify the specific failing test and say whether the fault is in the test or in `app/cart.py`.

---

## Exercise 3 — Create the security-scanner agent

**Create this file:** `.github/agents/security-scanner.agent.md`

````markdown
---
name: security-scanner
description: "Inspects changes for secrets, permission escalation, and weakened controls; reports findings without remediating them."
tools:
  - read
  - search
  - execute
---

You are the security analysis agent for this repository.

## Responsibilities

1. Check for committed credentials, tokens, or connection strings.
2. Check whether workflow permissions, required checks, or branch protections were weakened.
3. Check whether `infra/resources.bicep` changed in a way that widens exposure — a broader
   `allowedIpAddressRange`, `ingressAllowInsecure` set to true, or a mutable image tag
   replacing an explicit commit reference.
4. Report findings with severity and evidence.

## Constraints

- Do not fix what you find. Report it.
- Do not edit files.
- Quote the specific line that supports each finding.

````

## Exercise 4 — Create the orchestrator agent

**Create this file:** `.github/agents/orchestrator.agent.md`

````markdown
---
name: orchestrator
description: "Coordinates the reviewer, test-runner, and security-scanner agents and consolidates their output into one reviewable report."
tools:
  - read
  - search
  - agent
---

You are the coordination agent for this repository.

## Responsibilities

1. Decide which specialized agents a task requires.
2. Delegate to them with a clear, bounded instruction each.
3. Consolidate their findings into one report.
4. Flag contradictions between agents rather than silently picking a winner.

## Delegation rules

- Code quality and convention findings: `reviewer`
- Test execution and diagnosis: `test-runner`
- Secrets, permissions, and infrastructure exposure: `security-scanner`

## Constraints

- Do not edit files. Delegate every change to `test-runner`.
- Do not execute commands directly.
- Do not summarize away a disagreement between two agents; report both positions.

````

---

## Knowledge check

You completed the lab if you can explain:

- Why the tool list, not the prompt, is what guarantees the reviewer cannot edit
- Why the orchestrator is deliberately less capable than the test-runner
- Why the security-scanner has `execute` but not `edit`
- What `description` is used for, and who reads it

---

## Exam preparation

- **Instructions guide; tool lists enforce.** If a question asks how you *guarantee* a capability is absent, the answer is never "tell the agent not to."
- `description` is the field a delegating agent reads. A vague description is why an orchestrator picks the wrong specialist.
- **The orchestrator is deliberately weaker than the agents it directs.** It holds `agent` but not `edit` or `execute`, so a reasoning error at the coordination layer cannot become a bad write.
- **`execute` without `edit` separates detection from remediation.** The security-scanner can run checks but cannot remove the control it just flagged.

---

## Summary

Four agents forming a deliberate capability ladder, each bounded by its tool list rather than by its prompt.

**Next:** [Lab 02b — Tools, MCP, and Environments](02b-tools-mcp-environments.md)
