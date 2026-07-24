# GH-600 Flashcards

## Domain 1: Prepare agent architecture and SDLC processes

**Q:** What is the safest first step before an agent modifies code?  
**A:** Require a structured plan that defines intent, scope, files, risks, validation, and approval status.

**Q:** What makes an agent task well-scoped?  
**A:** Clear inputs, allowed files, out-of-scope files, expected outputs, constraints, and success criteria.

**Q:** Why separate planning from execution?  
**A:** It lets humans or controls inspect and approve risky work before irreversible action.

**Q:** What is an SDLC anti-pattern for agents?  
**A:** Letting the agent make broad, unreviewed changes without artifacts or success criteria.

**Q:** What does GitHub provide in an agent workflow?  
**A:** A system of record and control plane through issues, branches, pull requests, checks, reviews, and audit trails.

## Domain 2: Implement tool use and environment interaction

**Q:** What principle should guide agent tool access?  
**A:** Least privilege based on task purpose.

**Q:** What is an MCP allow list?  
**A:** A control that limits which MCP tools an agent can use.

**Q:** What is the risk of broad MCP access?  
**A:** The agent may take actions outside its approved scope or increase blast radius.

**Q:** What should an agent use to inspect CI failures?  
**A:** Read-only access to workflow logs and artifacts.

**Q:** Why are workflow token permissions important?  
**A:** They define what actions a workflow or setup step can perform during execution.

**Q:** What should happen if an agent needs secrets?  
**A:** Deny by default or require explicit human approval with audited access.

**Q:** What boundaries define an agent execution environment?  
**A:** Repository, branch, workflow, runner, network, tool, token, and environment scope.

## Domain 3: Manage memory, state, and execution

**Q:** What is short-term memory?  
**A:** Task-local context used during an active run.

**Q:** What is long-term repository memory?  
**A:** Persisted repository facts such as conventions or build commands, scoped to the repository.

**Q:** Why validate memory before use?  
**A:** To prevent stale or incorrect context from influencing current work.

**Q:** What is durable state?  
**A:** Inspectable task progress stored in artifacts, plans, pull requests, logs, or issue comments.

**Q:** What is context drift?  
**A:** When an agent's assumptions no longer match the current repository or task state.

**Q:** How should an agent resume work safely?  
**A:** Read durable state, re-check current files, validate assumptions, and continue from recorded decisions.

## Domain 4: Perform evaluation, error analysis, and tuning

**Q:** Why are tests not enough to evaluate an agent?  
**A:** Tests may pass while scope, security, maintainability, or governance expectations are violated.

**Q:** Name common evaluation signals.  
**A:** Tests, scans, logs, traces, changed files, plan adherence, artifacts, and review comments.

**Q:** What are common agent failure classes?  
**A:** Reasoning error, tool misuse, context issue, environment issue, governance issue, and test coverage issue.

**Q:** When should instructions be tuned?  
**A:** When the agent repeatedly misunderstands scope, quality expectations, or required behavior.

**Q:** When should tool access be tuned?  
**A:** When the agent misuses tools or has more access than the task requires.

## Domain 5: Orchestrate multi-agent coordination

**Q:** What is the main risk of multi-agent execution?  
**A:** Conflicting, duplicated, or contradictory work without clear coordination.

**Q:** How can agents be isolated?  
**A:** Separate branches, worktrees, files, roles, tools, or execution scopes.

**Q:** What should every agent handoff include?  
**A:** Role, task state, decisions, changed files, validation, risks, and next action.

**Q:** What should happen when agents make conflicting changes?  
**A:** Detect overlap, stop automatic merge, and require coordinator or human review.

**Q:** What is a manager-worker pattern?  
**A:** A coordinating agent or human assigns scoped tasks to worker agents and consolidates outputs.

## Domain 6: Implement guardrails and accountability

**Q:** What are guardrails?  
**A:** Policies, permissions, runtime controls, reviews, and checks that keep agents within safe boundaries.

**Q:** Which files usually need special protection?  
**A:** Workflows, CODEOWNERS, MCP config, agent definitions, policies, secrets, and deployment settings.

**Q:** What GitHub controls enforce human review?  
**A:** Pull request reviews, CODEOWNERS, rulesets, required checks, and environment approvals.

**Q:** What is accountability evidence?  
**A:** Plans, pull requests, logs, checks, artifacts, review approvals, comments, and audit events.

**Q:** What action should agents usually not perform autonomously?  
**A:** Merge pull requests, deploy to production, access secrets, or weaken security controls.

