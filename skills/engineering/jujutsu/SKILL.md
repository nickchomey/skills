---
name: jujutsu
description: General jj (Jujutsu) procedures for revision selection, splits, merges, bookmarks, recovery, and workspace and Git worktree interop. Use when the task involves non-trivial revsets, history changes, conflict resolution, bookmark moves, publication, workspace or worktree lifecycle, or whenever you are tempted to reach for git CLI commands.
---

# Jujutsu procedures

This skill covers generic jj behavior that applies in any repository. Repo-specific workflows (baseline bookmarks, wrapper scripts, runtime isolation) live in that repo's own docs. Check its AGENTS.md for an overlay before acting.

## Always use jj

Use `jj` for all version control reads and writes. Never substitute raw git commands:

| Instead of | Run |
| --- | --- |
| `git status` | `jj status` |
| `git log` | `jj log` (add `--ignore-working-copy` only after a `jj status` snapshot, see below) |
| `git diff` | `jj diff --git` (path lists: `jj diff --name-only`, never both flags together) |
| `git add` plus `git commit` | Edit files; the edits land in `@` on their own at the next snapshot. `jj describe -m 'type(scope): description'` only labels `@`, it seals nothing |
| `git stash` | `jj new -m 'type(scope): description'` (the old work stays as the parent) |
| `git checkout -b` | `jj new -r REV -m 'type(scope): description'` |
| `git fetch`, `git push` | `jj git fetch`, `jj git push -b NAME` |
| `git worktree add` | `jj workspace add` (see references/workspaces.md first) |

`jj git ...` handles Git transport and `gh` handles GitHub. A repo may define its own push gate (alias or script); follow it when AGENTS.md names one.

## Select the intended change

There is no staging area and no uncommitted state. `@` is an ordinary commit that tracks the files on disk: every edit amends it automatically at the next snapshot, so `jj status` always diffs `@` against its parent, even when `@` already carries a full description. (jj reuses the words "working copy" to mean `@` itself, not a separate uncommitted layer.) `jj describe` only sets the message. `jj new` is what seals `@` and starts the next change. Never report "uncommitted changes", never ask anyone to commit before acting, and never reach for git porcelain to interpret `jj status` output: read `jj status` and `jj log`, and run `jj split` when the files in `@` belong to more than one logical unit.

1. Run `jj status` to snapshot actual files. Identify the current change, its parents, and whether its work belongs to the user, a prior task, or your active task.
2. Continue your own active logical change. Start an independent unit with `jj new -m 'type(scope): description'` rather than amending unrelated work. Use a new change on top of user work when that dependence is intentional; do not silently choose another base.
3. After each source-edit batch or history mutation, run `jj status`. Resolve working-copy conflicts before unrelated work. A preserved conflicted ancestor is allowed when its resolution is recorded in a clean child.

After that snapshot, read-only inspection may use `--ignore-working-copy`:

```sh
jj log --ignore-working-copy
jj diff --git --ignore-working-copy
jj evolog --ignore-working-copy
jj workspace list --ignore-working-copy
```

Use explicit templates for IDs and metadata, never parse graph symbols or colored human log output. For automation needing path lists, use `jj diff --name-only` without `--git`: requesting both can emit a patch as well as the summary.

## Split or rewrite

Inspect the exact source revision and selected paths first. For your own work, a non-interactive file split is:

```sh
jj split -m 'type(scope): describe the extracted unit' PATH...
jj status
```

Filesets and `-m` keep this out of editors. Hunk-level splitting needs human interaction; ask rather than invoking `jj split -i`, `jj diffedit`, or `jj arrange`. Do not squash a reviewed stack for publication. Rewriting an ancestor can affect descendants, shared bookmarks, and other workspaces: coordinate before changing user or shared history. Do not bypass immutability to make an assumed target writable.

## Preserve merge and conflict provenance

When combining two lines of history (vendor import plus local patches, upstream release plus downstream work), keep both lines as parents of a new merge rather than rebasing one onto the other:

```sh
jj new LINE_A LINE_B -m 'chore(vendor): merge upstream release'
jj status
```

If it conflicts, preserve that merge and create a child:

```sh
jj new @ -m 'fix(vendor): resolve upstream merge conflicts'
jj status
# Edit the conflict markers into the intended result, then:
jj status
jj diff --git
```

Do not automatically squash the resolution back into the merge, rebase the patches, or abandon the conflicted parent: that rewrites the evidence this workflow deliberately retains. Choosing an entire side with scoped `jj restore` is appropriate only after inspecting that side and deciding those specific changes should be replaced.

Sync by merging by default; rebase only when the result must stay a linear patch chain. For a full proof procedure on a branch sync, call the Skill tool with "merge-trunk-into-branch"; for porting a patch chain onto a new upstream release, call the Skill tool with "rebase-onto-upstream". Neither replaces a repo's own updater or export workflow: where the repo forbids rewriting its vendor line, follow that repo's overlay instead.

## Bookmarks and publication

Distinguish **publication bookmarks** from bookmarks a repo's own automation advances (a baseline a vendor importer moves, bookmarks inside disposable test repositories). Only the latter may advance as part of their authorized workflow without a push or PR request. They are never implicit publication targets; the repo's AGENTS.md names them.

For requested publication, identify the intended reviewed tip, not blindly `@` (it may be an empty continuation). A useful candidate query is:

```sh
jj log --no-graph -r 'heads(::@ & ~empty() & ~description(exact:""))' \
  -T 'change_id.short() ++ " " ++ description.first_line() ++ "\n"'
```

Inspect the result and intended stack; ask if multiple candidates remain. Use `jj bookmark create NAME -r REV` for a new bookmark, or `jj bookmark move NAME --to REV` for an existing one. Run `jj status` afterward. Spell out the target rather than using automatic bookmark advancement.

Fetch with `jj git fetch`, inspect local and remote bookmarks, and track a remote bookmark only when needed. Push only the requested bookmark with `jj git push -b NAME`. Target the repo's default branch unless told otherwise, preserve the stack, and use the requested language for PR text.

## Workspace and worktree decisions

**Before creating, adopting, converting, moving, or retiring a workspace**, read [the workspace procedure](references/workspaces.md). It provides the installed-capability gate, colocation and ignore-rule caveats, and safe lifecycle steps. Verify newer workspace commands against the installed version and its help.

One workspace remains the default unless the task gives a concrete reason for another. Extra working directories do not isolate runtimes, services, or databases on their own; confirm isolation per repo.

## Recovery

Before `jj undo`, `jj op restore`, `jj restore`, or `jj abandon`, inspect the exact operation, revision, or paths and the affected files. Preserve unexpected user files and capture revisions; do not use a broad reset as diagnosis.

If a particular workspace is stale, target it explicitly:

```sh
jj -R TARGET workspace update-stale
jj -R TARGET status
```

An unreachable path is not proof that a workspace was intentionally deleted. Use the workspace procedure before forgetting or removing anything. Neither `jj undo` nor an operation restore can recover ignored files deleted from disk.

This skill does not assume a Stop hook or run `jj fix` across mutable history. Inspect actual hook and formatter configuration and scope any formatting work to the authorized change.
