## Architecture

- This repository is a GH-600 study lab for governed agentic development.
- `app/` contains the cart module (`cart.py`) and its HTTP wrapper (`api.py`). Standard library only — do not add third-party dependencies.
- `tests/` contains the automated validation tests for the sample app and lab tasks.
- `labs/` contains the GH-600 exercise instructions the learner follows in order.
- `templates/` contains task templates and starter artifacts to be filled in by the learner.
- `solutions/` contains sample answers for review after an attempt is complete.
- `.github/` contains repo guidance, skills, and automation and should be treated as sensitive reviewable configuration.
- `infra/` holds the Bicep that deploys `app/` to Azure Container Apps, and `Dockerfile` builds its image; `tools/` holds support tooling. Treat all of these as sensitive paths and do not change them without review.

## Conventions

- Keep changes narrow and limited to the files required for the task.
- Do not refactor unrelated code or expand scope without clear need.
- Preserve existing behavior and public interfaces unless the task explicitly requires a change.
- Prefer readable, maintainable code with clear names and minimal unnecessary complexity.
- Keep edits easy to review and aligned with the repository structure.
- Use the existing project patterns and style already present in the repo.
- Produce a brief plan before editing code and keep the implementation within the approved task scope.

## Testing

- Run these tests from the repository root after code changes:

```bash
python3 -m unittest discover -s tests
```

- Validate the relevant behavior before comparing against the sample solution in `solutions/`.

## Security

- Never commit credentials, secrets, tokens, or sensitive environment values.
- Do not weaken workflow permissions, required checks, CODEOWNERS, branch protections, or security scans.
- Treat `.github/`, `tools/`, and `infra/` as sensitive paths that require reviewer attention.
- Stop and request human review before changing deployment settings, environment configuration, token permissions, or MCP server configuration.
- Keep every change reviewable and aligned with the repository's governed development workflow.
