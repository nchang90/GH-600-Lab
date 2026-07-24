# GH-600 Concept Diagrams

## Plan, act, evaluate lifecycle

```mermaid
flowchart LR
    Issue[Issue or task brief] --> Plan[Structured plan]
    Plan --> Gate{Approval needed?}
    Gate -->|No, low risk| Act[Agent acts within scope]
    Gate -->|Yes| Human[Human or CODEOWNER review]
    Human --> Act
    Act --> PR[Pull request]
    PR --> Checks[Tests, scans, workflow artifacts]
    Checks --> Eval[Evaluation and error analysis]
    Eval --> Tune[Tune instructions, tools, memory, workflow]
    Tune --> Issue
```

## GitHub as system of record and control plane

```mermaid
flowchart TD
    Task[Issues and task briefs] --> Branch[Agent branch]
    Branch --> PR[Pull request]
    PR --> Review[Human review and CODEOWNERS]
    PR --> Checks[Required checks and scans]
    PR --> Artifacts[Plans, logs, reports, traces]
    Review --> Decision{Accept?}
    Checks --> Decision
    Artifacts --> Decision
    Decision -->|Yes| Merge[Merge through policy]
    Decision -->|No| Rework[Agent rework or rollback]
```

## MCP tool permission flow

```mermaid
flowchart LR
    Agent[Agent] --> Request[Tool request]
    Request --> AllowList{MCP allow list}
    AllowList -->|Allowed| Scope{Task and permission scope}
    AllowList -->|Denied| Block[Block action]
    Scope -->|Within scope| Execute[Execute tool]
    Scope -->|Sensitive| Approval[Human approval]
    Approval --> Execute
    Execute --> Audit[Log or artifact]
```

## Multi-agent coordination

```mermaid
flowchart TD
    Coordinator[Coordinator or human] --> Planner[Planner agent]
    Coordinator --> Coder[Implementation agent]
    Coordinator --> Reviewer[Reviewer agent]
    Planner --> PlanArtifact[Plan artifact]
    Coder --> PR[Code branch and PR]
    Reviewer --> ReviewArtifact[Evaluation report]
    PlanArtifact --> Coordinator
    PR --> Coordinator
    ReviewArtifact --> Coordinator
    Coordinator --> Conflict{Conflict or degraded behavior?}
    Conflict -->|Yes| Escalate[Resolve, retry, rollback, or reassign]
    Conflict -->|No| Approve[Approve through normal controls]
```

## Guardrail approval path

```mermaid
flowchart TD
    Action[Proposed agent action] --> Risk{Risk classification}
    Risk -->|Low| Audit[Allow with audit]
    Risk -->|Medium| PRReview[Allow in PR with required review]
    Risk -->|High| OwnerReview[Require CODEOWNER or security review]
    Risk -->|Critical| HumanApproval[Require explicit approval before action]
    Risk -->|Forbidden| Block[Block]
    Audit --> Evidence[Preserve evidence]
    PRReview --> Evidence
    OwnerReview --> Evidence
    HumanApproval --> Evidence
    Block --> Evidence
```

