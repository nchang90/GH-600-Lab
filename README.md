# GH-600 Agentic Developer Study Lab

Self-paced, step-by-step labs for turning a conventional repository into a governed agentic one. Each lab tells you exactly which file to create, what to put in it, why that file exists, how to verify it, and what the exam expects you to remember.

Official study guide: <https://learn.microsoft.com/en-gb/credentials/certifications/resources/study-guides/gh-600>

## At a glance

- **Total duration:** about 3 hours 45 minutes, including preparation.
- **Environment:** your own fork, plus optional Azure resources for one exercise.
- **Estimated cost:** effectively free. The optional deployment scales to zero when idle and the image lives in GitHub Container Registry, which is free for public packages. [Tear down](labs/00-lab-preparation.md#6-teardown) when you finish regardless.

## Labs

Work through them in order — each builds on the last.

| Lab | Domain | Time | What you build |
| --- | --- | --- | --- |
| [00 — Lab Preparation](labs/00-lab-preparation.md) | Prerequisites | ~30 min | Fork, tooling, passing tests, Actions enabled |
| [01 — Prepare Agent Architecture](labs/01-agent-architecture-sdlc.md) | 1 | ~15 min | `.github/copilot-instructions.md` |
| [02 — Tool Use & Environment](labs/02-tools-mcp-environments.md) | 2 | ~45 min | Four agents, `.mcp.json`, execution boundaries |
| [03 — Memory, State & Execution](labs/03-memory-state-execution.md) | 3 | ~30 min | *(analysis)* Session logs, durable state |
| [04 — Evaluation, Error Analysis & Tuning](labs/04-evaluation-error-analysis-tuning.md) | 4 | ~30 min | A real change, tuned instructions, a PR that is the evaluation |
| [05 — Multi-Agent Coordination](labs/05-multi-agent-coordination.md) | 5 | ~40 min | Parallel agent review and consolidation in CI |
| [06 — Guardrails & Accountability](labs/06-guardrails-accountability.md) | 6 | ~35 min | Preventive hooks and an audit trail |

Lab 03 creates no files. It covers judgement the exam tests through log reading and scenario matching, and the concepts it establishes are applied directly in Labs 04 and 05.

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
.mcp.json                            External tool servers              (lab 02)
```

## Repo shape

| Path | Contains |
| --- | --- |
| `app/` | The cart module and its HTTP wrapper — what agents read, change, test, and deploy |
| `tests/` | The suite that provides evaluation evidence |
| `labs/` | The seven lab guides |
| `solutions/` | Sample answers, for after you attempt a lab |
| `templates/` | Starter files the labs fill in |
| `infra/` | Bicep for the cart API, deployed with `azd provision` |
| `tools/` | MCP allow-list design reference |
| `.github/skills/gh600-exam-coach/` | The lab-guide skill |

## How to use these guides

Start with [Lab 00](labs/00-lab-preparation.md). Every file-producing step ends with a **Verify** block — do not move on until it passes.

Verify with `test -s` rather than `test -f`. Creating a file in an editor does not write it to disk until you save, and `-f` passes on an empty file, which is the most common way to lose time in this lab.

Use the sample in `solutions/` only after you have attempted the step yourself.

## Conventions used in these guides

- **Create this file** — a file you must add to the repository.
- **Why this shape** — the reasoning behind the step.
- **Verify** — a command that proves the step worked.
- **Behavioural test** — a check that the artifact actually changed agent behaviour.
- **Exam notes** — facts that are commonly tested.

## Validate locally

```bash
python3 -m unittest discover -s tests
```

## The optional Azure deployment

[Lab 02](labs/02-tools-mcp-environments.md) reasons about a real deployment and the network boundary around it. The template is the teaching material — you can answer every question in that lab by reading [infra/resources.bicep](infra/resources.bicep) without deploying anything.

Deploy if you want Lab 04's evidence chain to reach a running service. [Lab 00, section 5](labs/00-lab-preparation.md#5-deploy-the-cart-api-optional) has the procedure, including [teardown](labs/00-lab-preparation.md#6-teardown).

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
