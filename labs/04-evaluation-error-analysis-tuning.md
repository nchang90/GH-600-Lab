# Lab 04: Perform Evaluation, Error Analysis, and Tuning

## Exam focus

- Define success criteria and evaluation signals.
- Analyze agent failures and identify root causes.
- Tune agent behavior based on evaluation results.

## Scenario

An agent attempted to add loyalty discount support but failed CI and modified an unrelated workflow. You need to evaluate the output, classify the failure, and tune future behavior.

## Tasks

### 1. Define evaluation signals

Open `templates/evaluation-report.md` and create `artifacts/evaluation-report-loyalty-discount.md`.

Include signals from:

- Unit tests
- Static checks
- Code review comments
- Changed file list
- Plan adherence
- Security scanning
- Workflow logs

### 2. Analyze the failed run

Read `artifacts/failed-agent-run.md`.

Classify each issue as one of:

- Reasoning error
- Tool misuse
- Context issue
- Environment issue
- Governance issue
- Test coverage issue

### 3. Tune instructions

Update `.github/copilot-instructions.md` with two improvements that would prevent the failure.

Do not add broad instructions like "be careful." Make the instructions measurable.

### 4. Tune tool access

Update `artifacts/mcp-allow-list-decision.md` or create it if you have not completed Lab 02. Explain which tool access should be changed and why.

## Self-check

You completed the lab if you can explain:

- Which signal detected each failure
- Whether the root cause was reasoning, tools, context, environment, or governance
- Which instruction changed
- Which tool permission changed
- How you would know the next run improved

## Exam notes

Evaluation is broader than "tests passed." GH-600 expects you to use plans, logs, traces, artifacts, workflow output, changed files, scans, and human review as evaluation signals.
