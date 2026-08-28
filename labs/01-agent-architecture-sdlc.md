# Lab 01 — Prepare Agent Architecture (Domain 1)

**Goal:** Give every agent that works in this repository a shared, written understanding of the repository, its working rules, and its safety boundaries.

**You will create:**

| Step | File | Purpose |
| --- | --- | --- |
| 1 | `.github/copilot-instructions.md` | Repository-wide context every agent reads |

**Prerequisite:** [Lab 00](00-lab-preparation.md) complete — the test command must pass before an instruction file can name it.

**Time:** About 15 minutes

---

## Step 1 — Create the repository instructions file

Create [`.github/copilot-instructions.md`](../.github/copilot-instructions.md) with the following content:

````markdown
# Repository Instructions

## Architecture

- This repository is a GH-600 study lab for governed agentic development.
- `app/` contains the cart module (`cart.py`) and its HTTP wrapper (`api.py`). Standard library only — do not add third-party dependencies.
- `tests/` contains the automated validation tests for the sample app and lab tasks.
- `labs/` contains the GH-600 exercise instructions the learner follows in order.
- `templates/` contains task templates and starter artifacts to be filled in by the learner.
- `solutions/` contains sample answers for review after an attempt is complete.
- `.github/` contains repository guidance, skills, and automation.
- `infra/` holds the Bicep that deploys `app/` to Azure Container Apps, and `Dockerfile` builds its image; `tools/` holds support tooling. Treat all of these as sensitive paths and do not change them without review.

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
````

## Step 2 — Verify the file

Run these commands from the repository root:

```bash
test -s .github/copilot-instructions.md \
  && echo "PASS: instructions file exists and is not empty"

grep -q "## Architecture" .github/copilot-instructions.md \
  && grep -q "## Conventions" .github/copilot-instructions.md \
  && grep -q "## Testing" .github/copilot-instructions.md \
  && grep -q "## Security" .github/copilot-instructions.md \
  && echo "PASS: required sections are present"

python3 -m unittest discover -s tests
```

Use `test -s` rather than `test -f`. The `-s` check fails when the file is empty.

### Behavioral check

Open Copilot Chat in this repository and ask:

> What test command should I run in this repository, and which paths require extra caution?

A correct response should name:

- `python3 -m unittest discover -s tests`
- `.github/`, `tools/`, and `infra/`

If the response is generic or incorrect, confirm that the instructions file is saved at `.github/copilot-instructions.md`.

---

## Self-check

You completed the lab if your instructions answer these questions:

- What is this repository?
- What should an agent do here?
- What should an agent not do?
- What test command should the agent run?
- Which paths need extra caution?

---

## Exam notes

- Repository instructions provide durable context; chat prompts provide temporary context.
- Plans and explanations are not evidence that an implementation is safe.
- Prefer reviewable evidence such as a diff, test result, scan result, or approval event.
- Match agent autonomy to task risk and grant the lowest useful capability.
- Require human review when a change affects sensitive configuration or governance.

---

## What you built

You created one repository-level instruction file that gives agents shared architecture, conventions, testing, and security guidance.

**Next:** [Lab 02 — Implement Tool Use and Environment Interaction](02-tools-mcp-environments.md)
