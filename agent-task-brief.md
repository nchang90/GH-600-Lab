# Agent Task Brief

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

## Constraints

## Execution boundaries

### Repository scope

- Work only in the repository named in this brief.
- Do not change files outside the approved file list.
- Treat `.github/`, `tools/`, and `infra/` as sensitive and do not edit them unless explicitly in scope.

### Branch scope

- Use only the branch named in this brief.
- Do not merge, rebase, or rename branches unless the brief says to.
- Do not create or modify release or protected branches.

### Workflow scope

- Use only the workflows named in this brief.
- Do not change workflow permissions, required checks, or job conditions unless the brief allows it.
- Do not bypass review or approval gates.

### Runner environment

- Use only the runner environment named in this brief.
- Do not assume extra tools, packages, or secrets are available.

### Network access

- Use only the network access explicitly allowed in this brief.
- Do not reach external services unless the brief names them.

### Secrets and variables

- Use only the secrets and variables named in this brief.
- Do not read, print, copy, or invent secret values.

### Infrastructure and secrets scope

- Reach the cart API and MCP tools only through the endpoints named in this brief.
- Do not change `allowedIpAddressRange`, ingress settings, or probe configuration in `infra/resources.bicep` as part of a task.
- Do not replace `cartApiImage` with a moving tag; the deployed build must stay identifiable.
- Do not add environment variables or secrets to the container definition.
- Treat `infra/` as sensitive, the same as `.github/` and `tools/`.
- Do not modify an execution boundary to make the current task succeed.

## Approval gate

- A human must review and approve the pull request before merge.
- Changes to `.github/`, `tools/`, or `infra/` require explicit approval.
- The agent must not deploy or merge changes.