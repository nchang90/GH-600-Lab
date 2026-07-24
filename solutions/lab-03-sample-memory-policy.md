# Lab 03 Sample: Memory Policy

## Short-term memory

Use active conversation context only for the current task. Do not rely on it as the source of truth after a pause or handoff.

## Long-term repository facts

Store stable repository conventions, build commands, validation commands, and architecture decisions only when they are supported by current repository evidence.

## User-level preferences

Use personal preferences only for interaction style and workflow preferences. Do not use them to override repository policy.

## External memory

Use issues, pull requests, task state artifacts, logs, and workflow artifacts for durable state.

## Expiration and pruning

Prune memory when it is stale, contradicted by current code, unused, or irrelevant to the active task.

## Reset rules

Reset task-local context when:

- The branch is rebased or replaced.
- Architecture changes invalidate prior assumptions.
- A human changes scope.
- Another agent takes ownership.

## Context drift check

Before resuming, re-read current source files, task brief, plan, and latest validation output. If current code contradicts stored memory, current code and approved artifacts win.

