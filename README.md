# GH-600 Agentic Developer Study Lab

This repository is a lab-only GH-600 exam practice space. Use the six hands-on labs to build the artifacts the exam expects: plans, tool boundaries, memory design, evaluation notes, coordination workflows, and guardrails.

Official guide: https://learn.microsoft.com/en-gb/credentials/certifications/resources/study-guides/gh-600

## Start here

1. Begin with [Lab 01](labs/01-agent-architecture-sdlc.md).
2. Work through the labs in order.
3. Compare your work with the matching sample solution after you attempt each lab.

## Repo shape

- `app/` contains the small sample app used by the labs.
- `labs/` contains the six lab instructions.
- `.github/submissions/` contains the artifacts you create while doing the labs.
- `solutions/` contains sample answers to review after you try the lab.
- `.github/agents/` contains the lab guide agent.
- `.github/skills/gh600-exam-coach/` contains the lab-only skill.
- `templates/` contains starter files referenced by the labs.

## How to use

1. Read the current lab and its required artifact.
2. Fill in the requested template or create the requested submission.
3. Keep changes inside the files named by the lab.
4. Use the lab self-check before comparing with the sample solution.

## Validate locally

```bash
python3 -m unittest discover -s tests
```
