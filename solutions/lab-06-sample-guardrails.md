# Lab 06 Guardrails and Accountability

## Autonomy matrix

| Action | Recommended level | Reason |
| --- | --- | --- |
| Edit application source code | Level 3 | Allowed in PR with required review |
| Edit tests | Level 3 | Allowed in PR with required review |
| Create branch | Level 2 | Low risk and auditable |
| Open pull request | Level 2 | Low risk and reviewable |
| Modify workflow permissions | Level 4 | High security impact |
| Modify CODEOWNERS | Level 4 | Changes review enforcement |
| Read Actions logs | Level 2 | Low risk, useful for debugging |
| Access secrets | Level 0 or 4 | Block unless exceptional approved need |
| Deploy to production | Level 4 | Requires environment approval |
| Merge pull request | Level 4 | Requires checks and human approval |

## Ruleset plan

- Protect default branch.
- Require pull request before merge.
- Require passing unit tests and security checks.
- Require CODEOWNER review for `.github/**`, `tools/**`, and `policies/**`.
- Block force pushes to protected branches.
- Require signed commits if organization policy requires them.
- Require branches created by agents to use a recognizable prefix such as `agent/`.

## CODEOWNERS review proposal

Record these paths in `.github/submissions/codeowners-review-proposal.md` before applying them to `.github/CODEOWNERS`:

- `.github/copilot-instructions.md` should require platform-owner review because it changes agent behavior.
- `.github/workflows/**` should require platform-owner review because it controls automation permissions and checks.
- `.github/agents/**` should require platform-owner review because it changes custom agent definitions.
- `tools/**` should require platform-owner review because it controls MCP and external tool access.
- `policies/**` should require security-owner review because it defines governance expectations.

## Accountability checklist

- Plan reviewed.
- Scope respected.
- Sensitive files reviewed.
- Tests and scans passed.
- Tool actions traceable.
- Human approvals captured.
- Rollback plan documented.
- Final PR description explains agent involvement and validation evidence.
