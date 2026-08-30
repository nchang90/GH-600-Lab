# Lab 00 — Lab Preparation

## Introduction

In this lab, you prepare a working environment for the GH-600 exercises. You configure your fork and local tools, verify the sample application, enable GitHub Actions, and optionally deploy the cart API to Azure.

**Estimated time:** 30 minutes

## Learning objectives

After completing this lab, you'll be able to:

- Confirm that the required local tools are available.
- Prepare a fork for governed agentic development.
- Run the repository's automated tests.
- Enable GitHub Actions for later exercises.
- Optionally deploy and remove the sample API.

## Prerequisites

- A GitHub account with access to GitHub Copilot in your IDE and Copilot CLI.
- For the optional deployment, an Azure subscription and permission to create a resource group.

## Scenario

Later labs assume that tests, workflows, and repository tools already work. You need to establish that baseline before adding agent instructions, custom agents, workflows, and guardrails.

**Lab output:** No repository files are created. This lab configures your fork, your machine, and optionally your Azure resource group.

## What this lab sets up

| Section | What you get | Required? |
| --- | --- | --- |
| [Exercise 1 — Verify prerequisites](#exercise-1--verify-prerequisites) | Tool versions the exercises assume | Yes |
| [Exercise 2 — Fork and clone the repository](#exercise-2--fork-and-clone-the-repository) | Your own copy to commit into | Yes |
| [Exercise 3 — Verify the sample application](#exercise-3--verify-the-sample-application) | A passing test command | Yes |
| [Exercise 4 — Enable GitHub Actions](#exercise-4--enable-github-actions) | Workflow runs on your fork | Yes |
| [Exercise 5 — Deploy the cart API](#exercise-5--deploy-the-cart-api-optional) | A running service for Labs 02 and 04 | Optional |
| [Exercise 6 — Remove the Azure resources](#exercise-6--remove-the-azure-resources) | No ongoing Azure charges | If you completed Exercise 5 |

Labs 01 through 06 assume Exercises 1 through 4 are complete. Only Lab 02b uses Exercise 5, and it tells you what to do if you skipped it.

---

## Exercise 1 — Verify prerequisites

| Tool | Minimum | Check with |
| --- | --- | --- |
| Git | 2.30 | `git --version` |
| Python | 3.12 | `python3 --version` |
| GitHub CLI | 2.40 | `gh --version` |
| Azure CLI | 2.60 | `az version` |
| Azure Developer CLI | 1.11 | `azd version` |

Azure CLI and Azure Developer CLI are needed only for Exercise 5. Everything else is required. Install azd with `brew install azure-dev-cli` on macOS, or see [the install guide](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd).

You also need:

- A GitHub account with access to GitHub Copilot in your IDE and Copilot CLI.
- For Exercise 5 only: an Azure subscription, and permission to create a resource group in it.

### Check your work

```bash
git --version && python3 --version && gh --version
```

---

## Exercise 2 — Fork and clone the repository

Fork this repository to your own account, then clone your fork:

```bash
gh repo fork <owner>/GH-600Lab --clone --remote
cd GH-600Lab
```

Work in your fork, not the original. Every lab commits files, and the exercises assume you can push a branch and open a pull request against your own `main`.

### Check your work

```bash
git remote -v
```

You should see `origin` pointing at your fork.

---

## Exercise 3 — Verify the sample application

The labs use a small Python cart module (`app/cart.py`) as the thing agents read, change, and test.

### Check your work

```bash
python3 -m unittest discover -s tests
```

Expected: `Ran 9 tests` followed by `OK`.

This exact command appears in `.github/copilot-instructions.md`, in the agent files you build in Lab 02a, and in both workflows. If it fails here, it fails everywhere downstream — which is the only reason this section exists.

---

## Exercise 4 — Enable GitHub Actions

Two labs run workflows, so enable it now:

1. Open your fork on GitHub → **Actions** tab.
2. Choose **I understand my workflows, go ahead and enable them**.

### Check your work

```bash
gh workflow list
```

You should see `Agent evaluation` and `Copilot setup steps`. If the command reports no workflows, Actions is still disabled.

---

## Exercise 5 — Deploy the cart API (optional)

Lab 02b reasons about a real deployment and the network boundary around it. You can complete it by reading [infra/resources.bicep](../infra/resources.bicep) without deploying anything — the template is the teaching material.

Deploy if you want the evidence chain in Lab 04 to reach a running service.

> **Cost.** The app scales to zero when idle, so an unused deployment is effectively free on the Consumption plan. The image lives in GitHub Container Registry, which is free for public packages. Still complete [Exercise 6](#exercise-6--remove-the-azure-resources) when you finish.

### Publish the image

```bash
gh workflow run publish-image.yml
gh run watch
```

The run prints the image reference. Make the package public once, under your repository's **Packages** settings, or the pull from Azure fails with an authentication error rather than a not-found.

> **Registry names are lowercase.** A GitHub repository may contain capitals; a container registry path may not. The workflow lowercases it — if you build the reference by hand, do the same or the push fails with `repository name must be lowercase`.

### Provision with azd

[Azure Developer CLI](https://learn.microsoft.com/azure/developer/azure-developer-cli/) deploys the Bicep. It creates the resource group, so there is nothing to create by hand, and it remembers your settings between runs.

```bash
azd auth login
azd env new gh600-lab
```

Set the two values the template needs:

```bash
azd env set ALLOWED_IP_RANGE "$(curl -s https://api.ipify.org)/32"

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner | tr '[:upper:]' '[:lower:]')
azd env set CART_API_IMAGE "ghcr.io/${REPO}-cart:$(git rev-parse HEAD)"

azd env get-values
```

Check both printed before continuing, then provision:

```bash
azd provision
```

azd prompts for a subscription and region the first time, then stores them. Re-running picks up the same environment — there is no resource group name to remember and no `<placeholder>` to substitute.

### Check your work

```bash
URL=$(azd env get-value CART_API_URL)

curl -s "$URL/healthz"

curl -s -X POST "$URL/total" \
  -d '{"items":[{"sku":"A","quantity":2,"unit_price":10.00}],"tax_rate":0.10}'
```

Expected: `{"status": "ok"}` and `{"total": 22.0}` — the same number `tests/test_api.py` asserts locally. That is the point: the deployed service and the test suite agree, so a passing test says something about what is running.

The first request after an idle period takes a few seconds. That is the cold start you bought by scaling to zero.

**Behavioural test:** request the same URL from a phone on mobile data. You should get a connection failure or `403`, because your phone's address is outside `ALLOWED_IP_RANGE`. That refusal is the control working, and Lab 02b asks you to reason about what it does and does not protect.

> **The API has no authentication.** The IP restriction is the only thing in front of it. Do not put credentials or private data behind this deployment, and do not widen the CIDR to make a failing request succeed.

## Exercise 6 — Remove the Azure resources

Azure resources bill until removed. One command removes the resource group and everything azd created in it:

```bash
azd down --purge --force
```

### Check your work

```bash
az group exists --name rg-gh600-lab
```

Expected: `false` once deletion completes.

`--purge` matters for services with soft delete, which would otherwise keep billing or block a redeploy under the same name. `--force` skips the confirmation prompt; drop it if you want to be asked.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `ModuleNotFoundError: No module named 'app'` | Not in the repository root | `cd` to the root and rerun |
| `gh workflow list` shows nothing | Actions not enabled on the fork | Exercise 4 |
| `repository name must be lowercase` | Registry path built from a repo name containing capitals | Lowercase it with `tr '[:upper:]' '[:lower:]'` |
| `azd provision` cannot find a parameter | `ALLOWED_IP_RANGE` or `CART_API_IMAGE` not set | `azd env get-values`, then `azd env set` the missing one |
| Container app never becomes ready | Startup probe failing on `/healthz` | `az containerapp logs show`; usually the image was never published or the package is private |
| Deployment succeeds, `curl` returns `403` | Your public IP changed since provisioning | `azd env set ALLOWED_IP_RANGE` with the new address, then `azd provision` |

---

## Summary

A fork you can commit to, a passing test command every later lab depends on, Actions enabled, and optionally a running cart API that serves the same code your tests cover.

**Next:** [Lab 01 — Prepare Agent Architecture](01-agent-architecture-sdlc.md)
