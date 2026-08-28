# Lab 00 — Lab Preparation

**Goal:** get a working lab environment before Lab 01, so that no exercise stops on a missing tool, an unenabled setting, or a failing test command.

**You will create:** no repository files — this lab configures your fork, your machine, and (optionally) your Azure resource group.

**Time:** About 30 minutes

---

## What this lab sets up

| Section | What you get | Required? |
| --- | --- | --- |
| [1. Prerequisites](#1-prerequisites) | Tool versions the exercises assume | Yes |
| [2. Fork and clone](#2-fork-and-clone) | Your own copy to commit into | Yes |
| [3. Verify the sample application](#3-verify-the-sample-application) | A passing test command | Yes |
| [4. Enable Actions](#4-enable-actions) | Workflow runs on your fork | Yes |
| [5. Deploy the cart API](#5-deploy-the-cart-api-optional) | A running service for Labs 02 and 04 | Optional |
| [6. Teardown](#6-teardown) | No ongoing Azure charges | If you did section 5 |

Labs 01 through 06 assume sections 1 to 4 are complete. Only Lab 02 uses section 5, and it tells you what to do if you skipped it.

---

## 1. Prerequisites

| Tool | Minimum | Check with |
| --- | --- | --- |
| Git | 2.30 | `git --version` |
| Python | 3.12 | `python3 --version` |
| GitHub CLI | 2.40 | `gh --version` |
| Azure CLI | 2.60 | `az version` |

Azure CLI is needed only for section 5. Everything else is required.

You also need:

- A GitHub account with access to GitHub Copilot in your IDE and Copilot CLI.
- For section 5 only: an Azure subscription and permission to create resources in an existing resource group.

**Verify:**

```bash
git --version && python3 --version && gh --version
```

---

## 2. Fork and clone

Fork this repository to your own account, then clone your fork:

```bash
gh repo fork <owner>/GH-600Lab --clone --remote
cd GH-600Lab
```

Work in your fork, not the original. Every lab commits files, and the exercises assume you can push a branch and open a pull request against your own `main`.

**Verify:**

```bash
git remote -v
```

You should see `origin` pointing at your fork.

---

## 3. Verify the sample application

The labs use a small Python cart module (`app/cart.py`) as the thing agents read, change, and test.

**Verify:**

```bash
python3 -m unittest discover -s tests
```

Expected: `Ran 9 tests` followed by `OK`.

This exact command appears in `.github/copilot-instructions.md`, in the agent files you build in Lab 02, and in both workflows. If it fails here, it fails everywhere downstream — which is the only reason this section exists.

---

## 4. Enable Actions

Two labs run workflows, so enable it now:

1. Open your fork on GitHub → **Actions** tab.
2. Choose **I understand my workflows, go ahead and enable them**.

**Verify:**

```bash
gh workflow list
```

You should see `Agent evaluation` and `Copilot setup steps`. If the command reports no workflows, Actions is still disabled.

---

## 5. Deploy the cart API (optional)

Lab 02 reasons about a real deployment and the network boundary around it. You can complete Lab 02 by reading [infra/main.bicep](../infra/main.bicep) without deploying anything — the template is the teaching material.

Deploy if you want the evidence chain in Lab 04 to reach a running service.

> **Cost.** The app scales to zero when idle, so an unused deployment is effectively free on the Consumption plan. The image lives in GitHub Container Registry, which is free for public packages — deliberately not an Azure Container Registry, whose Basic tier bills monthly whether or not you pull from it. Still complete [section 6](#6-teardown) when you finish.

### Publish the image

```bash
gh workflow run publish-image.yml
gh run watch
```

The run prints the image reference. Make the package public once, under your repository's **Packages** settings, or the pull from Azure will fail with an authentication error rather than a not-found.

### Validate before deploying

```bash
IMAGE="ghcr.io/$(gh repo view --json nameWithOwner -q .nameWithOwner)-cart:$(git rev-parse HEAD)"

az bicep build --file infra/main.bicep

az deployment group validate \
  --resource-group <resource-group> \
  --template-file infra/main.bicep \
  --parameters allowedIpAddressRange="$(curl -s https://api.ipify.org)/32" \
               cartApiImage="$IMAGE"
```

### Deploy

Review the validation output — resource names, region, image reference, and allowed CIDR — before continuing:

```bash
az deployment group create \
  --name cart-api \
  --resource-group <resource-group> \
  --template-file infra/main.bicep \
  --parameters allowedIpAddressRange="$(curl -s https://api.ipify.org)/32" \
               cartApiImage="$IMAGE"
```

**Verify:**

```bash
URL=$(az deployment group show \
  --resource-group <resource-group> --name cart-api \
  --query properties.outputs.cartApiUrl.value -o tsv)

curl -s "$URL/healthz"

curl -s -X POST "$URL/total" \
  -d '{"items":[{"sku":"A","quantity":2,"unit_price":10.00}],"tax_rate":0.10}'
```

Expected: `{"status": "ok"}` and `{"total": 22.0}` — the same number `tests/test_api.py` asserts locally. That is the point: the deployed service and the test suite agree, so a passing test says something about what is running.

The first request after an idle period takes a few seconds. That is the cold start you bought by scaling to zero.

**Behavioural test:** request the same URL from a phone on mobile data. You should get a connection failure or `403`, because your phone's address is outside `allowedIpAddressRange`. That refusal is the control working, and Lab 02 asks you to reason about what it does and does not protect.

> **The API has no authentication.** The IP restriction is the only thing in front of it. Do not put credentials or private data behind this deployment, and do not widen the CIDR to make a failing request succeed.

---

## 6. Teardown

Azure resources bill until removed. Deleting the deployment record does not delete the resources it created:

```bash
az group delete --name <resource-group> --yes --no-wait
```

**Verify:**

```bash
az group exists --name <resource-group>
```

Expected: `false` once deletion completes.

---

## What you set up

A fork you can commit to, a passing test command every later lab depends on, Actions enabled, and optionally a running cart API that serves the same code your tests cover.

**Next:** [Lab 01 — Prepare Agent Architecture](01-agent-architecture-sdlc.md)
