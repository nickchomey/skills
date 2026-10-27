# Workspace procedure

## Capability gate

Keep the existing workspace unless an additional checkout solves a concrete, authorized task. First inspect installed capabilities:

```sh
jj --version
jj workspace add --help
jj git --help
jj git colocation --help
```

Some versions can create a Git linked worktree from a jj workspace with colocation, but have no Git worktree `adopt` or `sync` subcommand. A Git-created worktree therefore does not automatically become a jj workspace. Re-check the installed version and command help before relying on newer or proposed functionality.

If a tool has already created a Git-only worktree, stop and inspect ownership; do not initialize an independent jj repo there as a substitute for adoption. Use newer adoption or sync functionality only after the installed help confirms it. Do not enable automatic sync or convert colocation merely to make a third-party tool happy.

Ignore rules are also shared state: jj reads the checkout's `.gitignore` and repository-level Git excludes. In a colocated linked worktree, `info/exclude` belongs to the shared Git repository, not that individual worktree. Do not use it as a per-workspace ignore mechanism or assume a worktree-specific Git config is honored by jj. Install the repository's local excludes before snapshotting generated files.

## Authorized creation

Snapshot the source workspace and choose the base deliberately. `-r BASE` creates a **new child of BASE**. Omitting it uses current `@`'s parents, not its work in progress. Use `-r @` only when dependence on current work is intended.

A repo may provide its own wrapper task for creating application workspaces (extra services, databases, hostnames, or generated config). Use the wrapper when AGENTS.md names one; use the manual command below only for a plain checkout, and record why the wrapper was unnecessary.

```sh
jj workspace add --name NAME --colocate -r BASE -m 'feat: task description' DESTINATION
jj status
jj -R DESTINATION status
```

Choose `--no-colocate` instead when no Git-aware checkout is needed. Specify the flag rather than relying on a creation default. Keep the destination outside the source checkout. Workspace names are not bookmarks; do not create a publication bookmark just because there is another workspace.

Record the destination, base, name, colocation choice, and owner in the handoff. Dependencies, ignored files, secrets, and test data are not copied. Before running services or importers there, establish the actual source mount, container visibility of shared jj and Git metadata, and service and data isolation. Do not assume a separate source directory makes shared state safe.

## Active work and stale state

History, bookmarks, and operations remain shared. Coordinate mutations to common ancestors. A new workspace is filesystem separation, not an independent repository.

Use `jj -R PATH ...` when targeting another workspace. If the target is stale:

```sh
jj -R PATH workspace update-stale
jj -R PATH status
```

Do not enable auto-update-stale or Git worktree auto-sync as an incidental fix. Differentiate stale state from a temporarily unavailable or moved path.

## Retirement

1. Inspect the exact target and run `jj -R TARGET status` to snapshot it. Inventory ignored and untracked files, secrets, and active processes separately from its diff.
2. Confirm whether the user wants to **retain files** or **delete the directory**. Prefer preservation when unspecified; shared metadata changes still require deliberate retirement.
3. From a surviving workspace, use an explicit name:

```sh
# Retain working files, but disconnect workspace and Git metadata:
jj workspace forget NAME
jj status
```

Only with explicit, scoped deletion permission and an ignored-file backup:

```sh
jj workspace remove NAME
jj status
```

`remove` deletes ignored and untracked files too. Snapshotting tracked source is not a backup of them. The main workspace cannot be removed. The installed version may require updating a stale **target** before removal succeeds; verify its state rather than retrying blindly. Inspect cleanup warnings. Never fall back to recursive shell deletion or broad Git pruning.
