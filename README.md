# GH-600 Agentic Developer Study Lab

This lab helps you study for **Exam GH-600: Developing in Agentic AI Systems** by practicing the six measured skill areas from the official Microsoft study guide.

Official guide: https://learn.microsoft.com/en-gb/credentials/certifications/resources/study-guides/gh-600

## What you will build

You will use this folder as a mock production repository and gradually turn it into a controlled agentic development environment. The labs focus on how to plan, operate, evaluate, govern, and coordinate GitHub-based coding agents.

The starter application is a small cart pricing module in `app/cart.py` with tests in `tests/test_cart.py`.

Start with the workbook guide: [labs/00-workbook-flow.md](labs/00-workbook-flow.md). It maps every lab to the artifacts you will create, the sample answer to compare against, and the sensitive-path rule used throughout the repository.

Run tests locally:

```bash
python3 -m unittest discover -s tests
```

## Exam prep additions

Use these after or alongside the hands-on labs:

| File | Purpose |
| --- | --- |
| [exam-cheatsheet.md](exam-cheatsheet.md) | Fast scenario-to-control exam review |
| [flashcards.md](flashcards.md) | Domain-grouped recall cards |
| [mock-exam.md](mock-exam.md) | 45 scenario-style practice questions with answer key |
| [diagrams.md](diagrams.md) | Mermaid diagrams for the major GH-600 concepts |
| [challenge-labs.md](challenge-labs.md) | Broken agent outputs to classify and fix |
| [capstone.md](capstone.md) | End-to-end final exam simulation |
| [readiness-tracker.md](readiness-tracker.md) | Domain scoring and weak-area tracker |
| [solutions/](solutions/) | Sample completed lab artifacts to compare against your work |

## Custom study agents

The `.github/agents/` folder contains sample custom agent profiles you can use or adapt in a GitHub custom agents repository:

| Agent | Purpose |
| --- | --- |
| [implementation-planner.agent.md](.github/agents/implementation-planner.agent.md) | Produces safe implementation plans before code changes |
| [gh600-study-coach.agent.md](.github/agents/gh600-study-coach.agent.md) | Coaches you through domains, weak areas, and exam readiness |
| [agent-output-evaluator.agent.md](.github/agents/agent-output-evaluator.agent.md) | Evaluates agent outputs using GH-600 criteria |
| [capstone-reviewer.agent.md](.github/agents/capstone-reviewer.agent.md) | Scores capstone responses and explains missed controls |

## Prerequisites

- GitHub account
- Basic GitHub Actions, branches, pull requests, and repository rules knowledge
- Access to GitHub Copilot features in your organization or personal account
- Optional admin access to a test GitHub repository for rulesets, environments, and CODEOWNERS enforcement

If you do not have admin access, complete the design and file-based exercises locally, then compare your work against the checklists.

## Exam domain map

| Official GH-600 skill area | Weight | Lab |
| --- | ---: | --- |
| Workbook flow and artifact map | N/A | [Lab 00](labs/00-workbook-flow.md) |
| Prepare agent architecture and SDLC processes | 15-20% | [Lab 01](labs/01-agent-architecture-sdlc.md) |
| Implement tool use and environment interaction | 20-25% | [Lab 02](labs/02-tools-mcp-environments.md) |
| Manage memory, state, and execution | 10-15% | [Lab 03](labs/03-memory-state-execution.md) |
| Perform evaluation, error analysis, and tuning | 15-20% | [Lab 04](labs/04-evaluation-error-analysis-tuning.md) |
| Orchestrate multi-agent coordination | 15-20% | [Lab 05](labs/05-multi-agent-coordination.md) |
| Implement guardrails and accountability | 10-15% | [Lab 06](labs/06-guardrails-accountability.md) |

## Recommended study schedule

| Day | Focus | Output |
| --- | --- | --- |
| 1 | Foundations and SDLC integration | Agent task brief and structured plan |
| 2 | Tooling, MCP, and execution boundaries | Tool inventory and MCP allow-list design |
| 3 | Memory and durable state | Memory policy and resume artifact |
| 4 | Evaluation and tuning | Evaluation report and improved instructions |
| 5 | Multi-agent workflows | Orchestration runbook and conflict plan |
| 6 | Guardrails and accountability | Autonomy matrix, ruleset plan, and audit checklist |
| 7 | Review | Complete the practice scenarios in this README |

## Best review order

1. Read [labs/00-workbook-flow.md](labs/00-workbook-flow.md).
2. Complete the six domain labs.
3. Compare your answers with `solutions/`.
4. Complete `challenge-labs.md`.
5. Complete `capstone.md`.
6. Read `exam-cheatsheet.md`.
7. Drill `flashcards.md`.
8. Take `mock-exam.md` timed.
9. Record your score in `readiness-tracker.md`.
10. Revisit the official study guide for any missed domain.

## How to use this lab

1. Read the workbook guide and the current lab's exam focus.
2. Work in this folder as if it were a repository where agents operate.
3. Create or update the requested learner artifacts under `artifacts/submissions/`.
4. Use the self-check sections to verify your answer.
5. Compare against the matching sample under `solutions/` after you finish.
6. If you have a test GitHub repository, push this folder and configure the repository settings described in each lab.

## Practice scenarios

Use these as exam-style prompts after finishing all labs.

### Scenario A: Agent plan approval

An implementation agent proposes to modify application code, workflow permissions, and repository secrets in one autonomous run.

You should be able to explain:

- Which actions require planning only, human approval, or full block
- Which GitHub controls enforce the decision
- Which artifacts prove the decision was reviewed

### Scenario B: MCP tool governance

A team wants to add a remote MCP server that can read tickets, create branches, and post deployment comments.

You should be able to explain:

- Required tools and permissions
- MCP allow-list and registry controls
- Repository, branch, and environment scope
- How to audit tool use after the run

### Scenario C: Context drift

An agent resumes a task after several days and starts applying an outdated architecture decision.

You should be able to explain:

- Which state artifact should have prevented the drift
- How memory expiration or validation affects the task
- How to correct the agent without losing useful progress

### Scenario D: Multi-agent conflict

Two agents update the same workflow file in parallel. One adds a security scan and the other relaxes permissions to make tests pass.

You should be able to explain:

- How to isolate work
- How to detect overlapping changes
- Which output wins and why
- How to preserve traceability in the final pull request

## Exam readiness checklist

You are ready when you can do the following without looking up notes:

- Separate planning, reasoning, and execution for an agent workflow.
- Define inputs, outputs, success criteria, and constraints for an agent task.
- Select tools and MCP servers using least privilege.
- Explain repository, branch, workflow, runner, and environment execution boundaries.
- Design memory and durable state that prevent stale or conflicting context.
- Use logs, traces, plans, scans, and artifacts to classify agent failures.
- Tune instructions, tools, workflows, and memory based on evaluation results.
- Coordinate multiple agents while avoiding duplicated work and conflicting changes.
- Apply autonomy levels, rulesets, CODEOWNERS, required checks, and human-in-the-loop gates.
