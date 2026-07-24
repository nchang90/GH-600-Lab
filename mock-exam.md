# GH-600 Mock Exam

Answer the questions without notes. Aim for 80 percent or higher before scheduling the real exam.

## Questions

1. An agent is asked to "modernize the checkout service" and immediately edits ten files. What should have happened first?
   A. Let the agent continue because modernization requires exploration  
   B. Require a structured plan with scope, risks, validation, and approval  
   C. Disable all agent access permanently  
   D. Merge only if tests pass

2. An agent needs to read issue details and CI logs but not modify repository settings. What permission model is best?
   A. Admin access for convenience  
   B. Read-only access to issues, repository content, and workflow logs  
   C. Write access to all GitHub APIs  
   D. Secret access with audit disabled

3. Two agents make changes to the same workflow file in separate branches. What is the safest response?
   A. Merge the branch with fewer changed lines  
   B. Require conflict review by a coordinator or human  
   C. Let both agents force push  
   D. Disable the workflow

4. A resumed agent relies on an old architecture decision. What should prevent this?
   A. More model temperature  
   B. Durable task state and current-code validation  
   C. A larger branch name  
   D. A longer issue title

5. Tests pass, but the agent weakened workflow permissions. Which evaluation signal catches this?
   A. Plan adherence and sensitive file review  
   B. Unit test count  
   C. Commit timestamp  
   D. Branch length

6. Which action should normally require human approval before execution?
   A. Reading source files  
   B. Running unit tests  
   C. Deploying to production  
   D. Creating a task plan

7. What is the purpose of CODEOWNERS in an agent workflow?
   A. Auto-format code  
   B. Require review from responsible owners for protected paths  
   C. Store secrets  
   D. Replace tests

8. An MCP server exposes read, write, admin, and delete tools. The task only needs read. What should you configure?
   A. Allow all tools because MCP is trusted  
   B. Allow only required read tools  
   C. Deny the server but grant repository admin  
   D. Disable pull requests

9. What is context drift?
   A. A merge conflict caused by tabs  
   B. A mismatch between agent assumptions and current task or repository state  
   C. A workflow syntax error  
   D. A stale branch name only

10. What is the strongest GitHub-native evidence that an agent change was reviewed?
    A. Local console output only  
    B. Pull request review, required checks, and preserved artifacts  
    C. A private note  
    D. The agent's confidence score

11. An agent modifies CODEOWNERS to avoid review. What should happen?
    A. Approve if tests pass  
    B. Block or require security/platform owner review  
    C. Ignore because CODEOWNERS is metadata  
    D. Let the agent merge itself

12. Which is a good success criterion?
    A. "Make it better"  
    B. "Tests pass and discount applies only when subtotal is at least 100.00"  
    C. "Use AI"  
    D. "Change as little as possible" only

13. Why persist task state as an artifact?
    A. To replace pull requests  
    B. To let agents resume and reviewers inspect decisions  
    C. To hide failed attempts  
    D. To avoid validation

14. An agent needs to create a branch and open a pull request for application code. Which autonomy level fits best?
    A. Blocked forever  
    B. Autonomous with audit or required review depending on organization policy  
    C. Full admin autonomy  
    D. Human-only with no automation

15. What should a reviewer inspect when an agent fails?
    A. Only final answer  
    B. Logs, plans, traces, changed files, outputs, and workflow artifacts  
    C. Only branch name  
    D. Only issue labels

16. Which change is best for repeated out-of-scope edits?
    A. Add "be careful" to instructions  
    B. Add measurable scope constraints and sensitive file checks  
    C. Increase runtime  
    D. Remove tests

17. What is a guardrail?
    A. Any prompt longer than 500 words  
    B. A policy, permission, review, check, or runtime constraint that controls agent behavior  
    C. A code comment  
    D. A local-only TODO

18. What is the best way to handle secrets in agent tasks?
    A. Put them in prompts  
    B. Deny by default and use approved secret mechanisms only when required  
    C. Commit them encrypted in source  
    D. Print them in logs for audit

19. A multi-agent workflow has no handoff artifacts. What is the main risk?
    A. Too many tests  
    B. Lost decisions, duplicated effort, and poor auditability  
    C. Better performance  
    D. Fewer branches

20. Which tool should evaluate agent output for known vulnerabilities?
    A. Code or dependency scanning  
    B. Branch name parser  
    C. Issue milestone  
    D. Markdown preview

21. An agent wants to merge its own pull request. What is the safest policy?
    A. Allow if it authored all commits  
    B. Require required checks and human/reviewer approval before merge  
    C. Skip CODEOWNERS  
    D. Merge only at night

22. What makes GitHub a control plane for agents?
    A. It stores only source code  
    B. It centralizes branches, PRs, checks, reviews, policies, and audit trails  
    C. It replaces all CI systems  
    D. It removes human review

23. What is tool misuse?
    A. The model picks the wrong noun in a comment  
    B. The agent uses a tool outside intended purpose or permission scope  
    C. A test assertion fails  
    D. A markdown file has a typo

24. When should memory be reset or pruned?
    A. Never  
    B. When stale, irrelevant, expired, or conflicting with current evidence  
    C. Before every test command  
    D. Only after merge

25. What should an MCP allow list include?
    A. Every available tool  
    B. Only approved tools needed for the agent's role and task  
    C. Secrets for all environments  
    D. Personal access tokens

26. Which answer best separates planning and action?
    A. The agent implements first, then writes a plan  
    B. The agent writes a plan, waits for approval if needed, then acts within scope  
    C. The agent merges after planning  
    D. The agent plans only in private memory

27. What should happen when an agent is stalled?
    A. Ignore it  
    B. Detect the stalled state, preserve artifacts, retry/escalate/reassign based on runbook  
    C. Delete all logs  
    D. Merge partial output

28. Which is a governance issue?
    A. Agent bypasses required review  
    B. Unit test has typo  
    C. Variable name is long  
    D. Commit message is short

29. Which artifact best supports post-hoc analysis?
    A. A deleted local terminal buffer  
    B. Plans, logs, changed files, checks, and review comments  
    C. A screenshot only  
    D. A vague chat message

30. Why protect MCP configuration files?
    A. They control external tool access and blast radius  
    B. They make tests faster  
    C. They are always generated files  
    D. They are never security relevant

31. Which is a context issue?
    A. Agent uses outdated file paths from a previous architecture  
    B. Agent cannot access internet because firewall blocks it  
    C. Unit test framework crashes  
    D. Reviewer requested changes

32. Which is an environment issue?
    A. Runner lacks required dependency or network access  
    B. Agent misunderstood task intent  
    C. Tool had too much permission  
    D. CODEOWNERS missing

33. What should a custom agent profile define?
    A. Purpose, inputs, outputs, tools, boundaries, and success criteria  
    B. Only a name  
    C. Production secrets  
    D. Default branch write permission

34. How should low-risk repetitive actions be handled?
    A. Fully blocked  
    B. Automated with audit where policy allows  
    C. Human approval for every command  
    D. Performed outside GitHub

35. How should high-risk irreversible actions be handled?
    A. Explicit authorization and controlled paths  
    B. Agent autonomy if tests pass  
    C. Hidden logs  
    D. No pull request

36. What does "least privilege" mean for agents?
    A. Grant only the minimum permissions and tools needed for the task  
    B. Grant admin and monitor later  
    C. Remove all tools  
    D. Use one token everywhere

37. What is a good rollback trigger?
    A. Any code comment  
    B. Failed required checks, detected policy violation, or production risk  
    C. Successful unit tests  
    D. A short plan

38. What should happen if an agent needs to edit a sensitive file not in the plan?
    A. Continue silently  
    B. Stop and request review or plan update  
    C. Rename the file  
    D. Force push

39. Which best describes evaluation tuning?
    A. Changing instructions, workflows, memory, or tools based on measured failures  
    B. Asking the same prompt again forever  
    C. Ignoring logs  
    D. Reducing visibility

40. What is an orchestration pattern?
    A. A way to coordinate agent roles, order, isolation, and handoffs  
    B. A branch naming typo  
    C. A secret format  
    D. A unit test style

41. Which answer best handles contradictory agent recommendations?
    A. Pick the newest recommendation automatically  
    B. Require coordinator or human decision with recorded rationale  
    C. Merge both  
    D. Delete the PR

42. What should be blocked by default?
    A. Reading repository source  
    B. Running tests  
    C. Accessing unrelated secrets  
    D. Creating a plan

43. What is the exam likely testing in agent scenarios?
    A. Judgment about controls, scope, risk, and accountability  
    B. Memorization only  
    C. Git command speed  
    D. UI color names

44. Which is the best evidence of plan adherence?
    A. The changed files and implementation match the approved plan  
    B. The agent says it followed the plan  
    C. The branch name contains "plan"  
    D. The PR is large

45. What is the safest response if an agent tries to weaken required status checks?
    A. Allow to unblock delivery  
    B. Block or require explicit security/platform review  
    C. Approve if app tests pass  
    D. Remove the ruleset

## Answer key

1. B
2. B
3. B
4. B
5. A
6. C
7. B
8. B
9. B
10. B
11. B
12. B
13. B
14. B
15. B
16. B
17. B
18. B
19. B
20. A
21. B
22. B
23. B
24. B
25. B
26. B
27. B
28. A
29. B
30. A
31. A
32. A
33. A
34. B
35. A
36. A
37. B
38. B
39. A
40. A
41. B
42. C
43. A
44. A
45. B

