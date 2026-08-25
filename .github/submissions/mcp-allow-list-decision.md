# MCP Allow-List Decision

## Allowed

- `repos.read`
- `issues.read`
- `pull_requests.read`
- `actions.logs.read`
- `work_items.read`

## Require human approval

- `issues.comment.write`
- `pull_requests.create`
- `branches.create`
- `work_items.comment.write`

## Denied

- `secrets.read`
- `environments.approve`
- `pull_requests.merge`
- `rulesets.write`
- `work_items.delete`
- `admin.write`

## Ownership

The MCP configuration is owned by the repository organization and should be reviewed by the platform owner before any change.
