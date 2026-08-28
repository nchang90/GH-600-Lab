---
on:
  schedule: weekly
  workflow_dispatch:

permissions:
  contents: read
  issues: read
  pull-requests: read

engine: copilot

tools:
  github:
    allowed:
      - get_file_contents
      - list_issues

safe-outputs:
  create-issue:
    title-prefix: "[coverage] "
    labels: [test-coverage, agent-generated]
    close-older-issues: true
---

# Weekly test coverage review

Review the cart application for behaviour that is implemented but not tested.

1. Read `app/cart.py` and `app/api.py`.
2. Read `tests/test_cart.py` and `tests/test_api.py`.
3. Identify each input validation or calculation branch in `app/` that no test exercises.
4. Check open issues first; do not raise one that already exists.

Open a single issue listing each gap as:

- **Function** — the function and the specific branch
- **Why it matters** — what breaks if that branch regresses
- **Suggested test** — the assertion that would cover it

Report only gaps you can point to a specific line for. If coverage is complete,
say so and list nothing.

Do not modify any file. This workflow proposes work; it does not perform it.
