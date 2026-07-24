# Agent Autonomy Matrix

Use this matrix in Lab 06.

| Action | Risk | Autonomy level | Required control | Evidence |
| --- | --- | --- | --- | --- |
| Edit application source code | Medium | TBD | Pull request review | Changed files, tests |
| Edit tests | Medium | TBD | Pull request review | Changed files, tests |
| Create a branch | Low | TBD | Branch naming policy | Branch event |
| Open a pull request | Low | TBD | PR template | Pull request |
| Modify workflow permissions | High | TBD | CODEOWNER review | Workflow diff |
| Modify CODEOWNERS | High | TBD | Security owner approval | CODEOWNER diff |
| Read Actions logs | Low | TBD | Read-only token | Log access trace |
| Access secrets | Critical | TBD | Human approval | Secret access record |
| Deploy to production | Critical | TBD | Environment approval | Deployment record |
| Merge a pull request | High | TBD | Required reviews and checks | Merge record |

## Levels

- Level 0: blocked
- Level 1: planning only
- Level 2: autonomous with audit
- Level 3: autonomous with required review
- Level 4: human approval required before action

