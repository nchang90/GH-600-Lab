# Sample: `.github/copilot-instructions.md`

## Architecture

- `app/cart.py` contains the sample cart pricing module.
- `tests/test_cart.py` contains the unit tests that prove cart behavior.
- `labs/` contains the GH-600 lab instructions.
- `solutions/` contains sample answers for review after an attempt.
- `.github/agents/` and `.github/skills/` contain lab-only agent guidance.

## Conventions

- Keep changes focused and preserve existing public behavior where possible.
- Keep application logic and tests small and readable.
- Prefer the existing repo structure instead of introducing extra abstractions.

## Testing

- Run `python3 -m unittest discover -s tests`
- Run relevant tests after every implementation change.

## Security

- Never commit credentials, tokens, or secrets.
- Never weaken review, approval, or branch protections.
- Treat `.github/`, `policies/`, and `tools/` as sensitive paths.
