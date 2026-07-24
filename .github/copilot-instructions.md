# Copilot Instructions

This repository is used for governed agentic development exercises.

## Required behavior

- Produce a structured plan before editing code.
- Keep implementation changes inside the approved task scope.
- Update or add tests for behavior changes.
- Preserve existing validation commands unless the task explicitly approves changing them.
- Treat `.github/`, `policies/`, and `tools/` as sensitive paths that require reviewer attention.
- Do not weaken workflow permissions, required checks, CODEOWNERS, or security scans to make a task pass.

## Validation

For Python changes, run:

```bash
python3 -m unittest discover -s tests
```

## Escalation triggers

Stop and request human review before changing:

- Secrets or variables
- Deployment environments
- Workflow token permissions
- CODEOWNERS
- MCP server configuration
- Custom agent definitions under `.github/agents/`
- Branch protection or ruleset policy
