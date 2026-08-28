## Architecture

- This repository is a GH-600 study lab for governed agentic development.
- `app/` contains the small sample application used by the labs.
- `tests/` contains the automated validation tests for the sample app and lab tasks.
- `labs/` contains the GH-600 exercise instructions the learner follows in order.
- `templates/` contains task templates and starter artifacts to be filled in by the learner.
- `solutions/` contains sample answers for review after an attempt is complete.
- `.github/` contains repository guidance, skills, and automation.
- `infra/` and `tools/` contain the Azure deployment and support tooling.

## Conventions

- Produce a brief plan before editing code.
- Keep changes narrow and within the approved task scope.
- Do not refactor unrelated code or expand scope without a clear need.
- Preserve existing behavior and public interfaces unless the task requires a change.
- Follow the existing project structure, patterns, and style.
- Keep code readable, maintainable, and easy to review.

## Testing

- Run the test suite from the repository root after code changes:

```bash
python3 -m unittest discover -s tests
```

- Validate the relevant behavior before comparing your work with `solutions/`.

## Security

- Never commit credentials, secrets, tokens, or sensitive environment values.
- Do not weaken workflow permissions, required checks, CODEOWNERS, branch protections, or security scans.
- Treat `.github/`, `tools/`, and `infra/` as sensitive paths that require reviewer attention.
- Stop and request human review before changing deployment settings, environment configuration, token permissions, MCP server configuration, CODEOWNERS, or branch protection.
- Keep every change reviewable through the repository's governed development workflow.
