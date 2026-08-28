# Lab 01 — Prepare Agent Architecture (Domain 1)

**Goal:** Give every agent that works in this repository a shared, written understanding of the repository, its working rules, and its safety boundaries.

**You will create:**

| Step | File | Purpose |
| --- | --- | --- |
| 1 | `.github/copilot-instructions.md` | Repository-wide context every agent reads |
| 2 | `templates/agent-task-brief.md` | Inputs, outputs, and success criteria for one task |
| 3 | — | Map the agent lifecycle onto the GitHub surfaces that record it |

**Prerequisite:** [Lab 00](00-lab-preparation.md) complete — the test command must pass before an instruction file can name it.

**Time:** About 25 minutes

---

## Step 1 — Create the repository instructions file

**Create this file:** `.github/copilot-instructions.md`

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

**Verify:**

```bash
test -s .github/copilot-instructions.md \
  && echo "PASS: instructions file exists and is not empty"

for h in Architecture Conventions Testing Security; do
  grep -q "## $h" .github/copilot-instructions.md \
    && echo "PASS: $h" || echo "FAIL: $h missing"
done
```

Use `test -s`, not `test -f`. An empty file passes `-f` and is the most common way to lose time here.

**Behavioural test:** open Copilot Chat and ask *"What test command should I run in this repository, and which paths require extra caution?"* It should name `python3 -m unittest discover -s tests` and `.github/`, `tools/`, `infra/`. A generic answer means the file is not being read — check it is saved at `.github/copilot-instructions.md`.

---

## Step 2 — Define inputs, outputs, and success criteria

**Update this file:** `templates/agent-task-brief.md`

The headings `## Inputs`, `## Expected outputs`, and `## Success criteria` are already there and empty. Fill them for one concrete task — adding a loyalty discount to the cart, the task Lab 04 uses:

```markdown
## Inputs

- `app/cart.py` — current calculation, including the `tax_rate < 0` guard
- `tests/test_cart.py` — existing coverage that must keep passing
- `.github/copilot-instructions.md` — the test command and sensitive paths

## Expected outputs

- A discount applied to the subtotal before tax
- Tests covering zero, negative, and above-1.0 discount values
- A branch and a pull request; no direct commit to `main`

## Success criteria

- `python3 -m unittest discover -s tests` passes, with a higher test count than before
- `git diff --name-only main...HEAD` lists only `app/cart.py` and `tests/test_cart.py`
- Every pre-existing guard is still present in `calculate_total`
- The pull request states which criterion each change satisfies
```


## Step 3 — Trace the agent lifecycle through GitHub

No file to create. Agent work is only governable if each stage of it lands somewhere a human can inspect. Run these against your own fork and record which surface holds which evidence:

```bash
git log --format='%h  %an  %s' -5
gh pr list --state all --limit 5
gh run list --limit 5
```

Then complete the table:

| Lifecycle stage | What it produces | Which GitHub surface holds it |
| --- | --- | --- |
| **Plan** | The intended change and its scope | ? |
| **Act** | The change itself | ? |
| **Evaluate** | Evidence the change is correct | ? |

<details>
<summary>Answers</summary>

| Stage | Produces | Surface |
| --- | --- | --- |
| **Plan** | Intent and scope | The issue, and the task brief from Step 3 |
| **Act** | The change | A branch and its commits, then the pull request |
| **Evaluate** | Evidence | Check runs, workflow logs, uploaded artifacts, and review events |

None of these is the agent's chat history. That is the point: **GitHub is the system of record, and the agent's context is not.** A decision that exists only in a session cannot be reviewed, cannot be audited after the session ends, and cannot be handed to anyone else.

</details>

### Traceability

Check whether agent-authored work is attributable:

```bash
git log --format='%h %s%n    trailers: %(trailers:key=Co-authored-by,valueonly)' -5
```

An agent-generated commit should carry a `Co-authored-by` trailer naming the agent. If yours are blank, nothing in the history distinguishes what a person wrote from what an agent wrote — which is the first question asked after an incident.

**Answer before moving on:** if an agent opened a pull request that broke production, which of the surfaces above tells you *what it was asked to do*, and which tells you *what it actually did*? They are different surfaces, and an audit needs both.

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

- **An assistant suggests; an agent acts.** The distinction is not model capability, it is whether output reaches the repository without a human keystroke in between. Everything in these labs exists because the second kind needs boundaries the first does not.
- **GitHub is the system of record and the control plane.** Branches, pull requests, checks, logs, and review events are where agent work becomes reviewable. Chat history is none of those.
- **The agent lifecycle is plan → act → evaluate**, and each stage must leave an artifact. A stage with no artifact cannot be governed.
- **Traceability means attribution plus intent.** `Co-authored-by` trailers say who acted; the issue and task brief say what was asked. An audit needs both.
- Agent-generated work enters through the same contributor model as human work — branch, pull request, review, merge. Agents get no separate path.

- Repository instructions provide durable context; chat prompts provide temporary context.
- Plans and explanations are not evidence that an implementation is safe.
- Prefer reviewable evidence such as a diff, test result, scan result, or approval event.
- Match agent autonomy to task risk and grant the lowest useful capability.
- Require human review when a change affects sensitive configuration or governance.

---

## What you built

You created one repository-level instruction file that gives agents shared architecture, conventions, testing, and security guidance.

**Next:** [Lab 02 — Implement Tool Use and Environment Interaction](02-tools-mcp-environments.md)
