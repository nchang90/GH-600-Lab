# GH-600 Agentic Developer Study Lab

Self-paced, Microsoft Learn-style guided labs for turning a conventional repository into a governed agentic one. Each lab includes an introduction, learning objectives, prerequisites, a scenario, task-focused exercises, checks, exam preparation, and a summary.

Official study guide: <https://learn.microsoft.com/en-gb/credentials/certifications/resources/study-guides/gh-600>

Official learning paths:

- [Developing in Agentic AI Systems Part 1 of 2](https://learn.microsoft.com/en-us/training/paths/gh-developing-agentic-systems-1/)
- [Developing in Agentic AI Systems Part 2 of 2](https://learn.microsoft.com/en-us/training/paths/github-agentic-systems-part-two/github-agentic-systems-part-two)

## At a glance

- **Total duration:** about 4 hours 25 minutes, including preparation.
- **Environment:** your own fork, plus optional Azure resources for one exercise.
- **Estimated cost:** effectively free. The optional deployment scales to zero when idle and the image lives in GitHub Container Registry, which is free for public packages. Complete [Lab 00, Exercise 6](labs/00-lab-preparation.md#exercise-6--remove-the-azure-resources) when you finish regardless.

## Labs

Work through them in order — each builds on the last.

| Lab | Domain | Time | What you build |
| --- | --- | --- | --- |
| [00 — Lab Preparation](labs/00-lab-preparation.md) | Prerequisites | ~30 min | Fork, tooling, passing tests, Actions enabled |
| [01 — Prepare Agent Architecture](labs/01-agent-architecture-sdlc.md) | 1 | ~25 min | `.github/copilot-instructions.md`, task brief, lifecycle trace |
| [02a — Build Custom Agents](labs/02a-custom-agents.md) | 2 | ~25 min | Four agents with graduated tool lists |
| [02b — Tools, MCP & Environments](labs/02b-tools-mcp-environments.md) | 2 | ~30 min | `.vscode/mcp.json`, boundaries, cloud agent, agentic workflow |
| [03 — Memory, State & Execution](labs/03-memory-state-execution.md) | 3 | ~40 min | *(analysis)* Session logs, durable state |
| [04 — Evaluation, Error Analysis & Tuning](labs/04-evaluation-error-analysis-tuning.md) | 4 | ~30 min | A real change, tuned instructions, a PR that is the evaluation |
| [05 — Multi-Agent Coordination](labs/05-multi-agent-coordination.md) | 5 | ~40 min | Parallel agent review and consolidation in CI |
| [06 — Guardrails & Accountability](labs/06-guardrails-accountability.md) | 6 | ~45 min | Preventive hooks and an audit trail |

Lab 03 creates no files. It covers judgement the exam tests through log reading and scenario matching, and the concepts it establishes are applied directly in Labs 04 and 05.

## Microsoft Learn curriculum alignment

These guided labs turn the six official Microsoft Learn modules into one continuous repository project. Some modules are split into multiple labs so each exercise remains focused and independently verifiable.

| Microsoft Learn module | Guided lab |
| --- | --- |
| [Foundations of Agentic AI in GitHub](https://learn.microsoft.com/en-us/training/modules/foundations-agentic-ai/) | Lab 01 lifecycle and traceability exercises |
| [Designing Agent Architecture and SDLC Integration](https://learn.microsoft.com/en-us/training/modules/design-agent-architecture-integration/) | Lab 01 |
| [Tooling, MCP, and Agent Execution Environments](https://learn.microsoft.com/en-us/training/modules/agent-tooling-mcp-execution-environments/) | Labs 02a and 02b |
| [Multi-Agent systems and orchestration](https://learn.microsoft.com/en-us/training/modules/multi-agent-systems-orchestration/) | Lab 02a custom-agent setup and Lab 05 orchestration |
| [Memory, State, and Evaluation](https://learn.microsoft.com/en-us/training/modules/memory-state-evaluation/) | Labs 03 and 04 |
| [Governance, guardrails, and operations](https://learn.microsoft.com/en-us/training/modules/governance-guardrails-operations/) | Lab 06 |

## What you end up with

```
.github/
├── copilot-instructions.md          Repository-wide conventions        (lab 01)
├── agents/
│   ├── reviewer.agent.md            read, search                       (lab 02)
│   ├── test-runner.agent.md         read, search, edit, execute        (lab 02)
│   ├── security-scanner.agent.md    read, search, execute              (lab 02)
│   └── orchestrator.agent.md        read, search, agent                (lab 02)
├── hooks/
│   ├── pre-tool-policy.json         Hook configuration                 (lab 06)
│   └── scripts/                     Deny dangerous commands, audit edits
└── workflows/
    ├── copilot-setup-steps.yml      Cloud agent environment
    └── agent-evaluation.yml         Tests, scope check, agent review,
                                     consolidation                      (lab 05)
.vscode/mcp.json                     External tool servers              (lab 02)
```

## Repo shape

| Path | Contains |
| --- | --- |
| `app/` | The cart module and its HTTP wrapper — what agents read, change, test, and deploy |
| `tests/` | The suite that provides evaluation evidence |
| `labs/` | The eight lab guides |
| `infra/` | Bicep for the cart API, deployed with `azd provision` |
| `tools/` | MCP allow-list design reference |
| `.github/skills/gh600-exam-coach/` | The lab-guide skill |

## How to use these guides

Start with [Lab 00](labs/00-lab-preparation.md). Work through each numbered exercise in order, and do not continue until its **Check your work** instructions pass.

Verify with `test -s` rather than `test -f`. Creating a file in an editor does not write it to disk until you save, and `-f` passes on an empty file, which is the most common way to lose time in this lab.

## Conventions used in these guides

- **Lab scenario** — the role and problem that frame the exercises.
- **Learning objectives** — the skills you should gain from the lab.
- **Create this file** — a file you must add to the repository.
- **Why this shape** — the reasoning behind the exercise.
- **Check your work** — commands or observations that prove the exercise worked.
- **Knowledge check** — questions that confirm you understand the design choices.
- **Exam preparation** — facts and distinctions that are commonly tested.

## Validate locally

```bash
python3 -m unittest discover -s tests
```

## The optional Azure deployment

[Lab 02b](labs/02b-tools-mcp-environments.md) reasons about a real deployment and the network boundary around it. The template is the teaching material — you can answer every question in that lab by reading [infra/resources.bicep](infra/resources.bicep) without deploying anything.

Deploy if you want Lab 04's evidence chain to reach a running service. [Lab 00, Exercise 5](labs/00-lab-preparation.md#exercise-5--deploy-the-cart-api-optional) has the procedure, including [resource removal](labs/00-lab-preparation.md#exercise-6--remove-the-azure-resources).

The deployment ships the same `app/cart.py` your tests cover:

- a resource group, created by azd from your environment name
- an Azure Container Apps managed environment (`avm/res/app/managed-environment`)
- an Azure Container App (`avm/res/app/container-app`) running the image built by `publish-image.yml`
- HTTPS-only ingress on port `8000`, restricted to one reviewed client CIDR
- startup and readiness probes on `/healthz`
- `minReplicas: 0`, so an idle deployment costs nothing

Kept cheap on purpose: no Log Analytics workspace (ingestion is billed per GB), no Azure Container Registry (Basic tier bills monthly — `azure.yaml` has no `services:` block precisely so azd does not create one), and the smallest valid CPU and memory pairing.

Deploy with `azd provision`, remove with `azd down --purge`.

> The API has **no authentication**. The IP restriction is the only control in front of it. Do not put credentials or private data behind this deployment.

References:

- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [Deploy Bicep files with Azure CLI](https://learn.microsoft.com/azure/azure-resource-manager/bicep/deploy-cli)
