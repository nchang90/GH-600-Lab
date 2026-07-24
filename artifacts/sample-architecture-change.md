# Sample Architecture Change

## Change

Cart pricing will remain in `app/cart.py`, but discount rules must be implemented as explicit parameters to `calculate_total` rather than hidden global configuration.

## Reason

Pricing must remain deterministic in tests and reviewable in pull requests. Hidden global configuration makes agent changes harder to evaluate and increases context drift risk.

## Agent implication

Any resumed task that assumes discounts are read from global configuration is stale. The agent must re-read `app/cart.py`, current tests, the task brief, and the latest plan before continuing.

