# Lab 01 Sample: Agent Plan

## Intent

Add a loyalty discount so carts with a subtotal of at least 100.00 receive a 10 percent discount before tax.

## Scope

Allowed:

- Application pricing code
- Unit tests for pricing behavior
- Task state and evaluation artifacts

Out of scope:

- Workflow permissions
- CODEOWNERS
- Secrets
- Deployment configuration
- MCP configuration

## Proposed changes

- Add an explicit discount parameter or loyalty discount option to the total calculation.
- Keep existing validation for negative quantities, prices, and tax rates.
- Add tests for subtotal below threshold, subtotal at threshold, and subtotal above threshold.

## Files expected to change

- `app/cart.py`
- `tests/test_cart.py`

## Files explicitly out of scope

- `.github/**`
- `tools/**`
- `policies/**`
- `.github/agents/**`

## Risks

- Regressing tax calculation order
- Applying the discount below threshold
- Hiding discount behavior in global state
- Changing unrelated validation behavior

## Validation plan

- Run unit tests.
- Confirm changed files match approved scope.
- Confirm no sensitive paths changed.
- Confirm task state records decisions and validation.

## Approval decision

Approved for implementation because the change is limited to application code and tests. Any need to edit governance, workflow, MCP, or policy files must stop the implementation and require human review.
