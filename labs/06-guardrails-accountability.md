# Lab 06: Implement Guardrails and Accountability

## Exam focus

- Define autonomy levels.
- Implement guardrails and human-in-the-loop workflows.
- Scope permissions and execution contexts.
- Preserve accountability without blocking low-risk work.

## Scenario

Leadership wants agents to move faster, but security requires controls for sensitive files, secrets, workflows, and deployment paths.

## Tasks

### 1. Complete the autonomy matrix

Open `policies/agent-autonomy-matrix.md`.

Classify these actions:

- Edit application source code
- Edit tests
- Create a branch
- Open a pull request
- Modify GitHub Actions workflow permissions
- Modify CODEOWNERS
- Read Actions logs
- Access secrets
- Deploy to production
- Merge a pull request

Use these levels:

- Level 0: blocked
- Level 1: planning only
- Level 2: autonomous with audit
- Level 3: autonomous with required review
- Level 4: human approval required before action

### 2. Propose governance-file protection

Review `.github/CODEOWNERS`.

Create `artifacts/submissions/codeowners-review-proposal.md` listing any missing paths that should require owner review, especially:

- Copilot instructions
- MCP configuration
- GitHub Actions workflows
- Agent policy files
- Custom agent definitions

If you apply the proposal to `.github/CODEOWNERS` in a real repository, treat it as a sensitive-path change that requires platform-owner review before merge.

### 3. Design repository rules

Create `artifacts/submissions/repository-ruleset-plan.md` with required rules for:

- Default branch protection
- Required pull request reviews
- Required status checks
- Code owner review
- Signed commits, if required by your organization
- Agent-created branch naming

### 4. Create an accountability checklist

Create `artifacts/submissions/accountability-checklist.md` that a reviewer can use before approving an agent-created pull request.

Include:

- Plan reviewed
- Scope respected
- Tests and scans passed
- Sensitive files reviewed
- Tool actions traceable
- Human approvals captured
- Rollback plan documented

## Self-check

You completed the lab if you can justify:

- Why some actions are safe to automate
- Why some actions require human judgment
- Which GitHub controls enforce the policy
- Which artifacts preserve accountability
- How to keep approvals focused on material risk

## Exam notes

For GH-600, avoid extremes. Fully blocking agents reduces velocity, while unrestricted autonomy creates risk. The strongest answers right-size intervention by operational, security, and compliance risk.
